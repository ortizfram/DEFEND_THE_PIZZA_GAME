"""Shared helpers for DEFEND THE PIZZA! procedural Zombie Munchie blockouts.

Run only inside Blender (tested on Blender 5.2.3 LTS, headless `-b --factory-startup`).
No add-ons, no third-party assets: every mesh is built from bmesh primitives.

Conventions (documented in art/briefs/DTP-3D-003_Zombie_Munchie.md):
- 1 Blender unit = 1 Roblox stud (Unit System = None, FBX "Apply Scalings: FBX Unit Scale").
- Z up, character faces -Y (Blender Front view looks at the face).
- Character LEFT = +X. Root empty at world origin, feet on Z = 0.
- Each rigid part's origin sits on its future joint (neck, shoulder, elbow, hip, knee...).
"""
import json
import math
import os

import bmesh
import bpy
from mathutils import Euler, Matrix, Vector

# Colors come from art/design_tokens.json (sRGB hex). Derived tints are flagged.
TOKENS = {
    "zombieGreen": "#77CA63",
    "mint": "#59C9BE",
    "tomato": "#EF5A4C",
    "white": "#FFFFFF",
    "stroke": "#233142",
    "background": "#FFF7E7",
    "primary": "#FFD166",
}


def srgb_to_linear(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def hex_rgba(h):
    h = h.lstrip("#")
    return tuple(srgb_to_linear(int(h[i:i + 2], 16) / 255.0) for i in (0, 2, 4)) + (1.0,)


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.preferences.filepaths.save_version = 0  # no .blend1 backups
    scene = bpy.context.scene
    scene.unit_settings.system = "NONE"  # Roblox recommendation: unitless, 1 BU = 1 stud
    scene.unit_settings.system_rotation = "DEGREES"
    return scene


_MATS = {}


def material(name, hexcol, rough=0.55):
    if name in _MATS and _MATS[name].name in bpy.data.materials:
        return _MATS[name]
    mat = bpy.data.materials.new(name)
    try:
        mat.use_nodes = True  # deprecated (always on) in 5.x, harmless
    except Exception:
        pass
    bsdf = next((n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
    if bsdf is None:
        bsdf = mat.node_tree.nodes.new("ShaderNodeBsdfPrincipled")
        out = next(n for n in mat.node_tree.nodes if n.type == "OUTPUT_MATERIAL")
        mat.node_tree.links.new(bsdf.outputs[0], out.inputs[0])
    bsdf.inputs["Base Color"].default_value = hex_rgba(hexcol)
    bsdf.inputs["Roughness"].default_value = rough
    mat.diffuse_color = hex_rgba(hexcol)  # Workbench / viewport color
    mat["source_hex"] = hexcol
    _MATS[name] = mat
    return mat


# ---------------------------------------------------------------- primitives
def _sphere(u, v):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=u, v_segments=v, radius=1.0)
    return bm


def _apply(bm, fn):
    for vert in bm.verts:
        vert.co = fn(vert.co.copy())


def _place(bm, loc=(0, 0, 0), rot=(0, 0, 0)):
    R = Euler([math.radians(a) for a in rot], "XYZ").to_matrix()
    L = Vector(loc)
    _apply(bm, lambda c: L + R @ c)


def blob(size, loc, rot=(0, 0, 0), u=16, v=10, box=1.0, shape=None):
    """Ellipsoid / rounded box. size = half extents. box<1 -> boxier (superellipsoid)."""
    bm = _sphere(u, v)

    def f(c):
        if box != 1.0:
            c = Vector([math.copysign(abs(a) ** box, a) for a in c])
        if shape:
            c = shape(c)  # operates on unit-space coords (-1..1)
        return Vector((c.x * size[0], c.y * size[1], c.z * size[2]))

    _apply(bm, f)
    _place(bm, loc, rot)
    return bm


def capsule(p, q, r1, r2, u=10, v=6, flat=1.0):
    """Tapered capsule from p (radius r1) to q (radius r2). flat squashes local Y."""
    p, q = Vector(p), Vector(q)
    d = q - p
    length = d.length
    R = Vector((0, 0, 1)).rotation_difference(d.normalized()).to_matrix()
    bm = _sphere(u, v)

    def f(c):
        top = c.z > 1e-5
        r = r2 if top else r1
        local = Vector((c.x * r, c.y * r * flat, c.z * r + (length if top else 0.0)))
        return p + R @ local

    _apply(bm, f)
    return bm


# ---------------------------------------------------------------- objects
class Rig:
    """Holds the root empty + parts so every script names/parents the same way."""

    def __init__(self, root_name, collection_name):
        self.col = bpy.data.collections.new(collection_name)
        bpy.context.scene.collection.children.link(self.col)
        self.root = bpy.data.objects.new(root_name, None)
        self.root.empty_display_type = "PLAIN_AXES"
        self.root.empty_display_size = 0.5
        self.col.objects.link(self.root)
        self.parts = {}
        self.pivots = {root_name: Vector((0, 0, 0))}

    def part(self, name, bms, mat, pivot, parent=None, role="geometry"):
        """Merge one or more bmesh pieces into a single object with origin at pivot."""
        if not isinstance(bms, (list, tuple)):
            bms = [bms]
        pivot = Vector(pivot)
        me = bpy.data.meshes.new(name)
        merged = bmesh.new()
        for piece in bms:
            tmp = bpy.data.meshes.new("_tmp")
            piece.to_mesh(tmp)
            piece.free()
            merged.from_mesh(tmp)
            bpy.data.meshes.remove(tmp)
        for vert in merged.verts:
            vert.co -= pivot
        for face in merged.faces:
            face.smooth = True
        bmesh.ops.recalc_face_normals(merged, faces=merged.faces)
        merged.to_mesh(me)
        merged.free()
        me.materials.append(mat)
        obj = bpy.data.objects.new(name, me)
        self.col.objects.link(obj)
        parent_obj = self.parts.get(parent, self.root) if parent else self.root
        obj.parent = parent_obj
        obj.location = pivot - self.pivots[parent_obj.name]
        obj["dtp_role"] = role
        self.parts[name] = obj
        self.pivots[name] = pivot
        return obj


# ---------------------------------------------------------------- palette texture
# Roblox's 3D Importer drops flat material colors (verified in Studio 2026-11-22), so every
# part samples one shared palette PNG instead. 4x4 grid of 64 px cells (mipmap-safe), each UV
# collapsed to its cell centre. Order is fixed: index -> (key, hex). Never reorder, only append.
PALETTE = [
    ("zombieGreen", "#77CA63"),
    ("mint", "#59C9BE"),
    ("tomato", "#EF5A4C"),
    ("white", "#FFFFFF"),
    ("stroke", "#233142"),
    ("paleGreenDerived", "#ADDC97"),
    ("primary", "#FFD166"),
    ("background", "#FFF7E7"),
]
PALETTE_GRID = 4
PALETTE_SIZE = 256
PALETTE_REL = "art/source/textures/T_Munchie_Palette.png"


def _palette_uv(index):
    col, row = index % PALETTE_GRID, index // PALETTE_GRID  # row counted from the bottom
    return ((col + 0.5) / PALETTE_GRID, (row + 0.5) / PALETTE_GRID)


def palette_image(root_dir):
    path = os.path.join(root_dir, *PALETTE_REL.split("/"))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img = bpy.data.images.new("T_Munchie_Palette", PALETTE_SIZE, PALETTE_SIZE, alpha=False)
    cell = PALETTE_SIZE // PALETTE_GRID
    px = [0.5, 0.5, 0.5, 1.0] * (PALETTE_SIZE * PALETTE_SIZE)  # unused cells: neutral grey
    for i, (_key, hexcol) in enumerate(PALETTE):
        h = hexcol.lstrip("#")
        rgb = [int(h[k:k + 2], 16) / 255.0 for k in (0, 2, 4)]  # byte image: sRGB values
        c0, r0 = (i % PALETTE_GRID) * cell, (i // PALETTE_GRID) * cell
        for y in range(r0, r0 + cell):
            base = (y * PALETTE_SIZE + c0) * 4
            for x in range(cell):
                px[base + x * 4:base + x * 4 + 4] = rgb + [1.0]
    img.pixels[:] = px
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    img.filepath = path
    img.pack()  # .blend stays self-contained
    # relative to art/source/*.blend once saved
    img.filepath = "//" + os.path.relpath(path, os.path.join(root_dir, "art", "source")).replace("\\", "/")
    return img


def apply_palette(rig, root_dir, mat_name="M_Munchie_Palette"):
    """Replace each part's flat material with one palette material + collapsed UVs."""
    img = palette_image(root_dir)
    mat = bpy.data.materials.new(mat_name)
    try:
        mat.use_nodes = True
    except Exception:
        pass
    nt = mat.node_tree
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs["Roughness"].default_value = 0.55
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.interpolation = "Closest"
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    by_hex = {hexcol.upper(): i for i, (_k, hexcol) in enumerate(PALETTE)}
    assignment = {}
    for name, obj in rig.parts.items():
        old = obj.data.materials[0]
        hexcol = str(old.get("source_hex", "")).upper()
        assert hexcol in by_hex, f"{name}: color {hexcol} missing from PALETTE"
        idx = by_hex[hexcol]
        u, v = _palette_uv(idx)
        me = obj.data
        if not me.uv_layers:
            me.uv_layers.new(name="UVMap")
        for loop_uv in me.uv_layers.active.data:
            loop_uv.uv = (u, v)
        me.materials[0] = mat
        assignment[name] = {"paletteIndex": idx, "key": PALETTE[idx][0], "hex": hexcol}
    for old in [m for m in bpy.data.materials if m.users == 0]:
        bpy.data.materials.remove(old)
    return {"texture": PALETTE_REL, "size": PALETTE_SIZE, "grid": PALETTE_GRID,
            "material": mat_name, "parts": assignment}


# ---------------------------------------------------------------- QA stats
def mesh_stats(rig, variant, extra=None):
    dg = bpy.context.evaluated_depsgraph_get()
    per_part, total_tris, nonmanifold = {}, 0, 0
    lo = Vector((1e9, 1e9, 1e9))
    hi = Vector((-1e9, -1e9, -1e9))
    mats = set()
    for name, obj in rig.parts.items():
        ev = obj.evaluated_get(dg)
        me = ev.to_mesh()
        tris = sum(len(p.vertices) - 2 for p in me.polygons)
        bm = bmesh.new()
        bm.from_mesh(me)
        nm = sum(1 for e in bm.edges if not e.is_manifold)
        bm.free()
        for vtx in me.vertices:
            w = obj.matrix_world @ vtx.co
            lo = Vector(map(min, lo, w))
            hi = Vector(map(max, hi, w))
        mats.update(m.name for m in obj.data.materials if m)
        per_part[name] = {"tris": tris, "nonManifoldEdges": nm,
                          "pivot": [round(a, 3) for a in obj.matrix_world.translation],
                          "parent": obj.parent.name if obj.parent else None,
                          "material": obj.data.materials[0].name}
        total_tris += tris
        nonmanifold += nm
        ev.to_mesh_clear()
    size = hi - lo
    stats = {
        "variant": variant,
        "blenderVersion": bpy.app.version_string,
        "units": "1 BU = 1 stud (Unit System None)",
        "facing": "-Y (Blender Front view), character left = +X",
        "totalTriangles": total_tris,
        "partCount": len(per_part),
        "materials": sorted(mats),
        "materialCount": len(mats),
        "nonManifoldEdgesTotal": nonmanifold,
        "boundsMin": [round(a, 3) for a in lo],
        "boundsMax": [round(a, 3) for a in hi],
        "sizeStuds_WxDxH": [round(a, 3) for a in size],
        "parts": per_part,
    }
    if extra:
        stats.update(extra)
    return stats


def write_json(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2)


# ---------------------------------------------------------------- render
def set_engine(scene, prefer="EEVEE"):
    options = ["BLENDER_EEVEE", "BLENDER_EEVEE_NEXT"] if prefer == "EEVEE" else ["BLENDER_WORKBENCH"]
    for eng in options:
        try:
            scene.render.engine = eng
            return eng
        except TypeError:
            continue
    scene.render.engine = "BLENDER_WORKBENCH"
    return "BLENDER_WORKBENCH"


def world(scene, hexcol=TOKENS["background"], strength=0.9):
    w = bpy.data.worlds.new("DTP_World")
    scene.world = w
    try:
        w.use_nodes = True
    except Exception:
        pass
    bg = next((n for n in w.node_tree.nodes if n.type == "BACKGROUND"), None)
    if bg is None:
        bg = w.node_tree.nodes.new("ShaderNodeBackground")
        out = next(n for n in w.node_tree.nodes if n.type == "OUTPUT_WORLD")
        w.node_tree.links.new(bg.outputs[0], out.inputs[0])
    bg.inputs[0].default_value = hex_rgba(hexcol)
    bg.inputs[1].default_value = strength
    w.color = hex_rgba(hexcol)[:3]
    return w


def preview_collection(name="Preview_NotForExport"):
    col = bpy.data.collections.get(name)
    if col is None:
        col = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(col)
    return col


def look_at(obj, target):
    d = Vector(target) - obj.location
    obj.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def camera(name, loc, target, ortho=None, lens=50, col=None):
    cam_data = bpy.data.cameras.new(name)
    if ortho:
        cam_data.type = "ORTHO"
        cam_data.ortho_scale = ortho
    else:
        cam_data.lens = lens
    cam = bpy.data.objects.new(name, cam_data)
    (col or preview_collection()).objects.link(cam)
    cam.location = Vector(loc)
    look_at(cam, target)
    return cam


def lights(col=None, scale=1.0):
    col = col or preview_collection()
    out = []
    for name, loc, energy, kind, size in (
        ("Key_Sun", (-6, -8, 12), 2.1, "SUN", 0.15),
        ("Fill_Area", (8, -6, 5), 220 * scale * scale, "AREA", 8 * scale),
        ("Rim_Area", (0, 9, 7), 260 * scale * scale, "AREA", 6 * scale),
    ):
        ld = bpy.data.lights.new(name, kind)
        ld.energy = energy
        if kind == "SUN":
            ld.angle = size
        else:
            ld.size = size
        lo = bpy.data.objects.new(name, ld)
        col.objects.link(lo)
        lo.location = Vector(loc) * (scale if kind != "SUN" else 1)
        look_at(lo, (0, 0, 2))
        out.append(lo)
    return out


def ground(size=40, col=None, hexcol="#E8D6B0"):
    me = bpy.data.meshes.new("Ground")
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=1, y_segments=1, size=size / 2)
    bm.to_mesh(me)
    bm.free()
    me.materials.append(material("M_Preview_Ground", hexcol, 0.9))
    obj = bpy.data.objects.new("Ground", me)
    (col or preview_collection()).objects.link(obj)
    return obj


def render(scene, cam, path, res=(1024, 1024), engine="EEVEE", samples=32, film_transparent=False):
    eng = set_engine(scene, engine)
    scene.camera = cam
    scene.render.resolution_x, scene.render.resolution_y = res
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = film_transparent
    scene.render.image_settings.file_format = "PNG"
    scene.view_settings.view_transform = "Standard"
    if eng.startswith("BLENDER_EEVEE"):
        try:
            scene.eevee.taa_render_samples = samples
        except Exception:
            pass
    os.makedirs(os.path.dirname(path), exist_ok=True)
    scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    return path


def silhouette_mode(scene, hexcol="#233142"):
    set_engine(scene, "WORKBENCH")
    sh = scene.display.shading
    sh.light = "FLAT"
    sh.color_type = "SINGLE"
    sh.single_color = hex_rgba(hexcol)[:3]
    sh.background_type = "WORLD"
    sh.show_shadows = False
    sh.show_cavity = False
    sh.show_object_outline = False
    scene.display.render_aa = "8"


def standard_previews(scene, rig, out_dir, prefix, height):
    """Front ortho + isometric-ish perspective, framed from model height."""
    col = preview_collection()
    lights(col)
    ground(col=col)
    world(scene)
    mid = (0, 0, height * 0.5)
    front = camera(f"CAM_{prefix}_Front", (0, -30, height * 0.5), mid, ortho=height * 1.25, col=col)
    d = height * 1.35  # 45 deg yaw, ~35 deg elevation, distance scaled to height
    iso = camera(f"CAM_{prefix}_Iso", (-d, -d, height * 0.5 + d * 1.0), mid, lens=50, col=col)
    paths = {
        "front": render(scene, front, os.path.join(out_dir, f"{prefix}_front.png")),
        "iso": render(scene, iso, os.path.join(out_dir, f"{prefix}_iso.png")),
    }
    return paths


def save_blend(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=path, compress=True)


def script_args():
    import sys
    argv = sys.argv
    return argv[argv.index("--") + 1:] if "--" in argv else []
