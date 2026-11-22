"""Variant B - MUNCHIE NOODLE (DTP-3D-003). Editable blockout, rigid-segment friendly.

Usage (from repo root):
  "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --factory-startup \
      --python tools/asset_generation/build_munchie_b.py
Outputs: art/source/Zombie_Munchie_B.blend, art/renders/munchie/B_front.png, B_iso.png,
         art/qa/Zombie_Munchie_B_stats.json
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import munchie_common as mc  # noqa: E402
from mathutils import Euler, Vector  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PALE_GREEN = "#ADDC97"  # DERIVED: 60% zombieGreen #77CA63 + 40% background #FFF7E7 (not a token yet)


def rotate_about(bm, pivot, rot):
    R = Euler([math.radians(a) for a in rot], "XYZ").to_matrix()
    P = Vector(pivot)
    for v in bm.verts:
        v.co = P + R @ (v.co - P)
    return bm


def build():
    scene = mc.reset_scene()
    M = {
        "skin": mc.material("M_Noodle_SkinPaleGreen", PALE_GREEN),
        "mint": mc.material("M_Noodle_ShortsMint", mc.TOKENS["mint"]),
        "tongue": mc.material("M_Noodle_TongueTomato", mc.TOKENS["tomato"]),
        "white": mc.material("M_Noodle_EyeWhite", mc.TOKENS["white"], 0.35),
        "dark": mc.material("M_Noodle_DarkSlate", mc.TOKENS["stroke"], 0.45),
    }
    rig = mc.Rig("Zombie_Munchie_B", "Zombie_Munchie_B")

    # ---------------- hips / torso: tall, narrow, leaning forward
    rig.part("LowerTorso", mc.blob((0.55, 0.4, 0.36), (0, 0.08, 2.55), u=12, v=8, box=0.7),
             M["mint"], pivot=(0, 0.08, 2.5))
    rig.part("UpperTorso", mc.capsule((0, 0.05, 2.75), (0, -0.3, 4.15), 0.42, 0.5, u=14, v=8, flat=0.75),
             M["skin"], pivot=(0, 0.05, 2.75), parent="LowerTorso")
    rig.part("Neck", mc.capsule((0, -0.32, 4.45), (0.05, -0.6, 4.95), 0.15, 0.13, u=8, v=4),
             M["skin"], pivot=(0, -0.32, 4.45), parent="UpperTorso")

    # ---------------- head group: tall egg head, hanging jaw, popping eyes, tilted
    hinge = (0.05, -0.6, 4.95)
    tilt = (10, -12, 0)

    def H(bm):
        return rotate_about(bm, hinge, tilt)

    def pear(c):
        return Vector((c.x * (1 - 0.12 * c.z), c.y, c.z))

    rig.part("Head", H(mc.blob((0.55, 0.5, 0.72), (0.05, -0.72, 5.55), u=18, v=12, shape=pear)),
             M["skin"], pivot=hinge, parent="Neck")
    rig.part("Eye_R", H(mc.blob((0.34, 0.26, 0.36), (-0.24, -1.12, 5.82), u=12, v=8)),
             M["white"], pivot=(-0.24, -1.12, 5.82), parent="Head", role="detail")
    rig.part("Eye_L", H(mc.blob((0.25, 0.2, 0.26), (0.34, -1.08, 6.0), u=12, v=6)),
             M["white"], pivot=(0.34, -1.08, 6.0), parent="Head", role="detail")
    rig.part("Pupils", [H(mc.blob((0.14, 0.05, 0.14), (-0.17, -1.37, 5.77), u=8, v=5)),
                        H(mc.blob((0.1, 0.04, 0.1), (0.41, -1.27, 6.06), u=8, v=5))],
             M["dark"], pivot=(0.1, -1.3, 5.9), parent="Head", role="detail")
    rig.part("Mouth", H(mc.blob((0.48, 0.28, 0.38), (0.05, -1.02, 4.95), u=10, v=8)),
             M["dark"], pivot=(0.05, -1.0, 5.0), parent="Head", role="detail")

    # jaw hangs open below the head (separate part = easy chomp animation)
    jaw_pieces = [H(mc.blob((0.6, 0.52, 0.19), (0.05, -1.05, 4.5), u=12, v=6, box=0.7))]
    rig.part("Jaw", jaw_pieces, M["skin"], pivot=hinge, parent="Head")
    rig.part("Teeth", [H(mc.blob((0.08, 0.05, 0.1), (x, -1.42, z), u=6, v=4, box=0.6))
                       for x, z in ((-0.26, 4.73), (0.08, 4.75), (0.34, 4.71))],
             M["white"], pivot=(0.05, -1.42, 4.73), parent="Jaw", role="detail")
    rig.part("Tongue", H(mc.capsule((0.15, -1.3, 4.64), (0.26, -1.62, 4.22), 0.15, 0.12, u=8, v=4, flat=0.5)),
             M["tongue"], pivot=(0.15, -1.3, 4.64), parent="Jaw", role="detail")

    # ---------------- long noodle arms with big floppy hands
    def arm(side, shoulder, elbow, wrist):
        s = "Right" if side < 0 else "Left"
        rig.part(f"{s}UpperArm", mc.capsule(shoulder, elbow, 0.18, 0.16, u=8, v=6),
                 M["skin"], pivot=shoulder, parent="UpperTorso")
        rig.part(f"{s}LowerArm", mc.capsule(elbow, wrist, 0.16, 0.15, u=8, v=6),
                 M["skin"], pivot=elbow, parent=f"{s}UpperArm")
        w, e = Vector(wrist), Vector(elbow)
        d = (w - e).normalized()
        side_v = d.cross(Vector((0, 0, 1)))
        if side_v.length < 1e-3:
            side_v = Vector((1, 0, 0))
        side_v.normalize()
        palm = w + d * 0.28
        rot = Vector((0, 0, 1)).rotation_difference(d).to_euler()
        pieces = [mc.blob((0.3, 0.17, 0.3), (0, 0, 0), u=10, v=6, box=0.85)]
        # orient palm blob along the forearm
        R = rot.to_matrix()
        for vv in pieces[0].verts:
            vv.co = palm + R @ vv.co
        for k in (-1, 0, 1):
            base = palm + d * 0.2 + side_v * (0.16 * k)
            tip = base + d * 0.42 + side_v * (0.1 * k)
            pieces.append(mc.capsule(base, tip, 0.075, 0.06, u=6, v=4))
        tb = palm - side_v * side * 0.25
        pieces.append(mc.capsule(tb, tb + d * 0.2 - side_v * side * 0.18, 0.075, 0.06, u=6, v=4))
        rig.part(f"{s}Hand", pieces, M["skin"], pivot=wrist, parent=f"{s}LowerArm")

    arm(-1, (-0.5, -0.25, 4.05), (-0.85, -0.95, 3.75), (-0.8, -1.95, 3.55))   # reaching forward
    arm(+1, (0.5, -0.25, 4.05), (0.85, -0.45, 3.05), (0.8, -0.85, 1.95))     # dangling past hips

    # ---------------- thin legs, bent knees, huge upturned shoes
    def toe_up(c):
        return Vector((c.x, c.y, c.z + 0.45 * max(0.0, -c.y) ** 2))

    for side in (-1, 1):
        s = "Right" if side < 0 else "Left"
        hip, knee, ankle = (side * 0.36, 0.1, 2.45), (side * 0.46, -0.28, 1.35), (side * 0.5, 0, 0.38)
        rig.part(f"{s}UpperLeg", mc.capsule(hip, knee, 0.21, 0.18, u=8, v=6), M["skin"], pivot=hip,
                 parent="LowerTorso")
        rig.part(f"{s}LowerLeg", mc.capsule(knee, ankle, 0.18, 0.17, u=8, v=6), M["skin"], pivot=knee,
                 parent=f"{s}UpperLeg")
        rig.part(f"{s}Foot", mc.blob((0.4, 0.85, 0.22), (side * 0.52, -0.4, 0.22), u=12, v=8, box=0.7,
                                     shape=toe_up),
                 M["dark"], pivot=ankle, parent=f"{s}LowerLeg")
    return scene, rig


def main():
    scene, rig = build()
    stats = mc.mesh_stats(rig, "B_MunchieNoodle", {
        "colorsHex": {"skin": PALE_GREEN + " (derived)", "shorts": "#59C9BE", "tongue": "#EF5A4C",
                      "eyes/teeth": "#FFFFFF", "pupils/mouth/shoes": "#233142"},
        "uniqueMotif": "hanging open jaw with dangling tongue, huge upturned shoes",
        "script": "tools/asset_generation/build_munchie_b.py",
    })
    height = stats["sizeStuds_WxDxH"][2]
    renders = mc.standard_previews(scene, rig, os.path.join(ROOT, "art", "renders", "munchie"), "B", height)
    stats["renders"] = {k: os.path.relpath(v, ROOT).replace("\\", "/") for k, v in renders.items()}
    blend = os.path.join(ROOT, "art", "source", "Zombie_Munchie_B.blend")
    mc.save_blend(blend)
    stats["sourceFile"] = "art/source/Zombie_Munchie_B.blend"
    mc.write_json(os.path.join(ROOT, "art", "qa", "Zombie_Munchie_B_stats.json"), stats)
    print("DTP_RESULT", stats["variant"], "tris", stats["totalTriangles"], "size", stats["sizeStuds_WxDxH"])


if __name__ == "__main__":
    main()
