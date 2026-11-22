"""Comparison renders for DTP-3D-003 Munchie A vs B.

Appends the real model collections from art/source/Zombie_Munchie_A.blend and _B.blend and
adds GRAY PROXIES (not assets) for scale/readability context: chef (~R15 avatar height),
Runner, Big Eater and the giant pizza. Proxies only exist inside this render scene.

Usage (from repo root):
  "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --factory-startup \
      --python tools/asset_generation/render_compare.py
Outputs (art/renders/munchie/): lineup_color.png, lineup_silhouette.png,
  lineup_100px_silhouette.png, lineup_100px_color.png, gamecam_mobile_844x390.png
"""
import math
import os
import sys

import bpy

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import munchie_common as mc  # noqa: E402
from mathutils import Vector  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "art", "renders", "munchie")
PROXY = "#8C96A3"


def append_model(blend, col_name):
    with bpy.data.libraries.load(blend, link=False) as (src, dst):
        dst.collections = [col_name]
    col = dst.collections[0]
    bpy.context.scene.collection.children.link(col)
    return bpy.data.objects[col_name]  # root empty has the collection's name


def proxy_col():
    col = bpy.data.collections.new("Proxies_NotAssets")
    bpy.context.scene.collection.children.link(col)
    return col


def add(col, name, bm, hexcol, root=None):
    me = bpy.data.meshes.new(name)
    for f in bm.faces:
        f.smooth = True
    bm.to_mesh(me)
    bm.free()
    me.materials.append(mc.material("M_Proxy_" + hexcol, hexcol, 0.7))
    obj = bpy.data.objects.new(name, me)
    col.objects.link(obj)
    if root:
        obj.parent = root
    return obj


def empty(col, name, loc, rot_z=0.0):
    e = bpy.data.objects.new(name, None)
    col.objects.link(e)
    e.location = Vector(loc)
    e.rotation_euler = (0, 0, math.radians(rot_z))
    return e


def chef_proxy(col, loc, rot_z=0.0):
    r = empty(col, "PROXY_Chef", loc, rot_z)
    for x in (-0.5, 0.5):
        add(col, "PROXY_Chef_Leg", mc.blob((0.45, 0.45, 1.0), (x, 0, 1.0), box=0.4, u=8, v=6), PROXY, r)
        add(col, "PROXY_Chef_Arm", mc.blob((0.42, 0.42, 1.0), (x * 3.0, 0, 3.0), box=0.4, u=8, v=6), PROXY, r)
    add(col, "PROXY_Chef_Torso", mc.blob((1.0, 0.5, 1.0), (0, 0, 3.0), box=0.4, u=8, v=6), PROXY, r)
    add(col, "PROXY_Chef_Head", mc.blob((0.6, 0.6, 0.6), (0, 0, 4.6), u=12, v=8), PROXY, r)
    add(col, "PROXY_Chef_Hat", mc.blob((0.6, 0.6, 0.6), (0, 0, 5.6), box=0.6, u=12, v=8), "#FFFFFF", r)
    add(col, "PROXY_Spatula_Handle", mc.capsule((1.5, -0.3, 2.2), (1.6, -1.2, 3.6), 0.12, 0.12, u=6, v=4), "#C9A26B", r)
    add(col, "PROXY_Spatula_Head", mc.blob((0.75, 0.12, 0.6), (1.65, -1.45, 4.2), box=0.5, u=10, v=6), "#B7C2CC", r)
    return r


def runner_proxy(col, loc, rot_z=0.0):
    r = empty(col, "PROXY_Runner", loc, rot_z)
    add(col, "PROXY_Runner_Body", mc.capsule((0, 0.2, 1.9), (0, -0.6, 3.4), 0.32, 0.36, u=8, v=6), PROXY, r)
    add(col, "PROXY_Runner_Head", mc.blob((0.5, 0.5, 0.55), (0, -0.9, 4.1), u=10, v=8), PROXY, r)
    for s in (-1, 1):
        add(col, "PROXY_Runner_Leg", mc.capsule((s * 0.3, 0.2, 1.9), (s * 0.35, -0.3 * s, 0.2), 0.16, 0.14, u=6, v=4), PROXY, r)
        add(col, "PROXY_Runner_Arm", mc.capsule((s * 0.4, -0.4, 3.2), (s * 0.5, 0.5 * s, 2.3), 0.13, 0.11, u=6, v=4), PROXY, r)
    return r


def bigeater_proxy(col, loc, rot_z=0.0):
    r = empty(col, "PROXY_BigEater", loc, rot_z)
    add(col, "PROXY_BigEater_Body", mc.blob((2.9, 2.4, 2.6), (0, 0, 3.4), u=16, v=10), PROXY, r)
    add(col, "PROXY_BigEater_Head", mc.blob((1.4, 1.2, 1.1), (0, -0.6, 6.4), box=0.7, u=12, v=8), PROXY, r)
    for s in (-1, 1):
        add(col, "PROXY_BigEater_Arm", mc.capsule((s * 2.6, -0.4, 4.2), (s * 3.3, -1.6, 2.6), 0.75, 0.7, u=8, v=6), PROXY, r)
        add(col, "PROXY_BigEater_Leg", mc.capsule((s * 1.3, 0, 1.4), (s * 1.4, 0, 0.5), 0.75, 0.7, u=8, v=6), PROXY, r)
    return r


def pizza_proxy(col, loc, radius=5.0):
    import bmesh
    r = empty(col, "PROXY_Pizza", loc)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=32, radius1=radius, radius2=radius, depth=0.5)
    for v in bm.verts:
        v.co.z += 0.25
    add(col, "PROXY_Pizza_Cheese", bm, mc.TOKENS["primary"], r)
    for i in range(8):  # pepperoni dots = 8 slices hint
        a = (i + 0.5) * math.tau / 8
        add(col, "PROXY_Pepperoni", mc.blob((0.6, 0.6, 0.12), (math.cos(a) * radius * 0.6, math.sin(a) * radius * 0.6, 0.52), u=10, v=4),
            mc.TOKENS["tomato"], r)
    return r


def label(col, text, loc, size=0.9):
    cu = bpy.data.curves.new("LBL_" + text, "FONT")
    cu.body = text
    cu.size = size
    cu.align_x = "CENTER"
    obj = bpy.data.objects.new("LBL_" + text, cu)
    obj.data.materials.append(mc.material("M_Label", mc.TOKENS["stroke"], 0.8))
    col.objects.link(obj)
    obj.location = Vector(loc)
    obj.rotation_euler = (math.radians(90), 0, 0)
    return obj


def main():
    scene = mc.reset_scene()
    a = append_model(os.path.join(ROOT, "art", "source", "Zombie_Munchie_A.blend"), "Zombie_Munchie_A")
    b = append_model(os.path.join(ROOT, "art", "source", "Zombie_Munchie_B.blend"), "Zombie_Munchie_B")
    pc = proxy_col()
    view = mc.preview_collection()
    mc.world(scene)
    mc.lights(view, scale=2.0)

    # ---------------- lineup (front ortho)
    xs = {"chef": -11.5, "A": -5.5, "B": 0.0, "runner": 5.5, "big": 12.5}
    chef = chef_proxy(pc, (xs["chef"], 0, 0))
    a.location = (xs["A"], 0, 0)
    b.location = (xs["B"], 0, 0)
    run = runner_proxy(pc, (xs["runner"], 0, 0))
    big = bigeater_proxy(pc, (xs["big"], 0, 0))
    labels = [label(pc, t, (xs[k], -4, -1.3)) for k, t in (
        ("chef", "CHEF proxy"), ("A", "A ROUND"), ("B", "B NOODLE"), ("runner", "Runner proxy"), ("big", "BigEater proxy"))]
    cam = mc.camera("CAM_Lineup", (0.5, -40, 3.6), (0.5, 0, 3.6), ortho=32, col=view)
    mc.render(scene, cam, os.path.join(OUT, "lineup_color.png"), res=(1600, 640), samples=32)
    mc.render(scene, cam, os.path.join(OUT, "lineup_100px_color.png"), res=(640, 256), samples=32)
    for lb in labels:
        lb.hide_render = True
    mc.silhouette_mode(scene)
    mc.render(scene, cam, os.path.join(OUT, "lineup_silhouette.png"), res=(1600, 640), engine="WORKBENCH")
    mc.render(scene, cam, os.path.join(OUT, "lineup_100px_silhouette.png"), res=(640, 256), engine="WORKBENCH")

    # ---------------- mobile game camera (Roblox default vertical FOV 70 deg), 844x390 landscape
    mc.ground(size=80, col=view)
    pizza_proxy(pc, (0, 0, 0))
    chef.location = (0, -7.5, 0)
    chef.rotation_euler = (0, 0, math.radians(180))  # chef faces +Y toward the incoming zombies
    a.location = (-4.5, 8.5, 0)
    a.rotation_euler = (0, 0, math.radians(-15))
    b.location = (4.0, 9.5, 0)
    b.rotation_euler = (0, 0, math.radians(15))
    run.location = (-11, 12, 0)
    big.location = (12, 14, 0)
    gc = mc.camera("CAM_GameMobile", (0, -21, 12), (0, 3, 2), col=view)
    gc.data.sensor_fit = "VERTICAL"
    gc.data.angle_y = math.radians(70)
    mc.render(scene, gc, os.path.join(OUT, "gamecam_mobile_844x390.png"), res=(844, 390), engine="EEVEE", samples=32)
    print("DTP_RESULT compare renders written to", OUT)


if __name__ == "__main__":
    main()
