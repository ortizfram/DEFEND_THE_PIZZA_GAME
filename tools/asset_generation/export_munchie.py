"""Export the chosen Munchie variant to FBX + GLB using Roblox's documented Blender settings,
then re-import both files into an empty scene and write a QA report.

Roblox docs (create.roblox.com/docs/art/blender, /art/modeling/export-requirements):
Unit System None; FBX: Limit to Selected, Forward Z, Up Y, Apply Scalings = FBX Unit Scale,
Path Mode Copy + Embed Textures, no leaf bones, no baked animation unless animated.

Usage (from repo root):
  "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --factory-startup \
      --python tools/asset_generation/export_munchie.py -- A
"""
import os
import sys

import bmesh
import bpy

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import munchie_common as mc  # noqa: E402
from mathutils import Vector  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def mesh_qa():
    """Geometry QA over every mesh object in the current scene (world space)."""
    dg = bpy.context.evaluated_depsgraph_get()
    tris = verts = nonman = zero_area = inward = faces = 0
    lo = Vector((1e9, 1e9, 1e9))
    hi = Vector((-1e9, -1e9, -1e9))
    mats = set()
    objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    for o in objs:
        me = o.evaluated_get(dg).to_mesh()
        bm = bmesh.new()
        bm.from_mesh(me)
        bm.transform(o.matrix_world)
        center = sum((v.co for v in bm.verts), Vector()) / max(1, len(bm.verts))
        for f in bm.faces:
            faces += 1
            tris += len(f.verts) - 2
            if f.calc_area() < 1e-9:
                zero_area += 1
            if (f.calc_center_median() - center).dot(f.normal) < 0:
                inward += 1
        nonman += sum(1 for e in bm.edges if not e.is_manifold)
        verts += len(bm.verts)
        for v in bm.verts:
            lo = Vector(map(min, lo, v.co))
            hi = Vector(map(max, hi, v.co))
        mats.update(m.name for m in o.data.materials if m)
        bm.free()
        o.evaluated_get(dg).to_mesh_clear()
    return {
        "meshObjects": len(objs), "triangles": tris, "vertices": verts, "faces": faces,
        "nonManifoldEdges": nonman, "zeroAreaFaces": zero_area,
        "facesPointingTowardPartCenter": inward,
        "inwardNote": "heuristic per part; small non-zero counts on concave/bent shapes are expected",
        "materials": sorted(mats),
        "sizeWxDxH": [round(a, 3) for a in (hi - lo)],
        "boundsMinZ": round(lo.z, 3),
    }


def main():
    args = mc.script_args()
    variant = (args[0] if args else "A").upper()
    name = f"Zombie_Munchie_{variant}"
    src = os.path.join(ROOT, "art", "source", f"{name}.blend")
    out_dir = os.path.join(ROOT, "art", "export")
    os.makedirs(out_dir, exist_ok=True)
    fbx = os.path.join(out_dir, f"{name}.fbx")
    glb = os.path.join(out_dir, f"{name}.glb")

    bpy.ops.wm.open_mainfile(filepath=src)
    col = bpy.data.collections[name]
    bpy.ops.object.select_all(action="DESELECT")
    for o in col.all_objects:
        if o.type == "MESH":
            o.select_set(True)
    bpy.context.view_layer.objects.active = next(o for o in col.all_objects if o.type == "MESH")
    source_qa = mesh_qa_for(col)

    bpy.ops.export_scene.fbx(
        filepath=fbx, use_selection=True, object_types={"MESH"},
        apply_unit_scale=True, apply_scale_options="FBX_SCALE_UNITS", global_scale=1.0,
        axis_forward="Z", axis_up="Y", use_mesh_modifiers=True, mesh_smooth_type="OFF",
        add_leaf_bones=False, bake_anim=False, path_mode="COPY", embed_textures=True,
    )
    bpy.ops.export_scene.gltf(filepath=glb, export_format="GLB", use_selection=True,
                              export_apply=True, export_yup=True)

    report = {"variant": variant, "blenderVersion": bpy.app.version_string,
              "fbxSettings": "selected meshes, Forward Z, Up Y, FBX Unit Scale, global 1.0, no leaf bones, no anim",
              "source": source_qa, "exports": {}}
    for path, importer in ((fbx, "fbx"), (glb, "gltf")):
        bpy.ops.wm.read_factory_settings(use_empty=True)
        if importer == "fbx":
            bpy.ops.import_scene.fbx(filepath=path)
        else:
            bpy.ops.import_scene.gltf(filepath=path)
        qa = mesh_qa()
        qa["file"] = os.path.relpath(path, ROOT).replace("\\", "/")
        qa["bytes"] = os.path.getsize(path)
        report["exports"][importer] = qa
    s = report["source"]
    for k, e in report["exports"].items():
        e["matchesSource"] = (e["triangles"] == s["triangles"] and e["meshObjects"] == s["meshObjects"]
                              and all(abs(a - b) < 0.01 for a, b in zip(e["sizeWxDxH"], s["sizeWxDxH"])))
    mc.write_json(os.path.join(ROOT, "art", "qa", f"{name}_export_qa.json"), report)
    print("DTP_RESULT", {k: (v["triangles"], v["sizeWxDxH"], v["matchesSource"]) for k, v in report["exports"].items()})


def mesh_qa_for(col):
    keep = {o.name for o in col.all_objects}
    hidden = []
    for o in bpy.context.scene.objects:
        if o.type == "MESH" and o.name not in keep:
            hidden.append(o)
    # temporarily unlink non-model meshes (preview ground) from the measurement
    saved = {o: list(o.users_collection) for o in hidden}
    for o, cols in saved.items():
        for c in cols:
            c.objects.unlink(o)
    qa = mesh_qa()
    for o, cols in saved.items():
        for c in cols:
            c.objects.link(o)
    return qa


if __name__ == "__main__":
    main()
