"""Variant A - MUNCHIE ROUND (DTP-3D-003). Editable blockout, rigid-segment friendly.

Usage (from repo root):
  "C:/Program Files/Blender Foundation/Blender 5.2/blender.exe" -b --factory-startup \
      --python tools/asset_generation/build_munchie_a.py
Outputs: art/source/Zombie_Munchie_A.blend, art/renders/munchie/A_front.png, A_iso.png,
         art/qa/Zombie_Munchie_A_stats.json
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import munchie_common as mc  # noqa: E402
from mathutils import Euler, Vector  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def rotate_about(bm, pivot, rot):
    R = Euler([math.radians(a) for a in rot], "XYZ").to_matrix()
    P = Vector(pivot)
    for v in bm.verts:
        v.co = P + R @ (v.co - P)
    return bm


def build():
    scene = mc.reset_scene()
    M = {
        "skin": mc.material("M_Munchie_SkinGreen", mc.TOKENS["zombieGreen"]),
        "belly": mc.material("M_Munchie_BellyMint", mc.TOKENS["mint"]),
        "bib": mc.material("M_Munchie_BibTomato", mc.TOKENS["tomato"]),
        "white": mc.material("M_Munchie_EyeWhite", mc.TOKENS["white"], 0.35),
        "dark": mc.material("M_Munchie_DarkSlate", mc.TOKENS["stroke"], 0.45),
    }
    rig = mc.Rig("Zombie_Munchie_A", "Zombie_Munchie_A")

    # ---------------- torso: short, wide drop shape (wider at the bottom)
    def drop(c):
        return Vector((c.x * (1 - 0.15 * c.z), c.y * (1 - 0.12 * c.z), c.z))

    rig.part("Body", mc.blob((1.15, 0.95, 0.95), (0, 0, 1.8), u=20, v=12, shape=drop),
             M["skin"], pivot=(0, 0, 1.15))
    rig.part("Belly", mc.blob((0.72, 0.32, 0.55), (0, -0.78, 1.6), u=12, v=6),
             M["belly"], pivot=(0, -0.78, 1.6), parent="Body", role="detail")

    def bib_shape(c):
        return Vector((c.x * (1 + 0.22 * c.z), c.y + 3.0 * c.x * c.x, c.z))

    rig.part("Bib", mc.blob((0.7, 0.1, 0.38), (0, -0.82, 2.3), u=14, v=6, box=0.8, shape=bib_shape),
             M["bib"], pivot=(0, -0.82, 2.55), parent="Body", role="detail")

    # ---------------- head group: big rounded box, cocked to one side
    neck = (0, -0.05, 2.55)
    tilt = (4, 7, 0)

    def head_taper(c):
        return Vector((c.x * (1 + 0.06 * c.z), c.y, c.z))

    def H(bm):
        return rotate_about(bm, neck, tilt)

    rig.part("Head", H(mc.blob((1.18, 1.0, 0.95), (0, -0.08, 3.38), u=20, v=12, box=0.55, shape=head_taper)),
             M["skin"], pivot=neck, parent="Body")
    # mismatched eyes: big right eye (-X), small left eye (+X) sitting higher
    rig.part("Eye_R", H(mc.blob((0.44, 0.3, 0.46), (-0.48, -1.0, 3.58), u=14, v=8)),
             M["white"], pivot=(-0.48, -1.0, 3.58), parent="Head", role="detail")
    rig.part("Eye_L", H(mc.blob((0.31, 0.24, 0.33), (0.52, -1.02, 3.7), u=12, v=8)),
             M["white"], pivot=(0.52, -1.02, 3.7), parent="Head", role="detail")
    rig.part("Pupils", [H(mc.blob((0.17, 0.07, 0.17), (-0.40, -1.27, 3.66), u=8, v=5)),
                        H(mc.blob((0.12, 0.05, 0.12), (0.60, -1.22, 3.62), u=8, v=5))],
             M["dark"], pivot=(0, -1.25, 3.64), parent="Head", role="detail")

    def lopsided(c):
        return Vector((c.x, c.y, c.z + 0.18 * c.x))

    rig.part("Mouth", H(mc.blob((0.46, 0.18, 0.3), (0.06, -1.0, 3.0), u=10, v=8, shape=lopsided)),
             M["dark"], pivot=(0.06, -1.0, 3.0), parent="Head", role="detail")
    rig.part("Teeth", [H(mc.blob((0.11, 0.06, 0.1), (-0.12, -1.15, 3.2), u=6, v=4, box=0.6)),
                       H(mc.blob((0.1, 0.06, 0.09), (0.2, -1.15, 3.24), u=6, v=4, box=0.6))],
             M["white"], pivot=(0.04, -1.15, 3.22), parent="Head", role="detail")
    rig.part("Tongue", H(mc.blob((0.2, 0.07, 0.1), (0.14, -1.15, 2.84), u=8, v=6)),
             M["bib"], pivot=(0.14, -1.15, 2.84), parent="Head", role="detail")
    rig.part("Hair", [H(mc.capsule((0.1, -0.1, 4.2), (0.25, -0.2, 4.75), 0.08, 0.055, u=6, v=4)),
                      H(mc.capsule((0.25, -0.2, 4.75), (0.52, -0.34, 4.66), 0.055, 0.04, u=6, v=4))],
             M["dark"], pivot=(0.1, -0.1, 4.25), parent="Head", role="detail")

    # ---------------- arms: thick, reaching forward, asymmetric (right high, left droopy)
    def arm(side, shoulder, elbow, wrist, hand):
        s = "Right" if side < 0 else "Left"
        rig.part(f"{s}UpperArm", mc.capsule(shoulder, elbow, 0.34, 0.3, u=10, v=6),
                 M["skin"], pivot=shoulder, parent="Body")
        rig.part(f"{s}LowerArm", mc.capsule(elbow, wrist, 0.3, 0.27, u=10, v=6),
                 M["skin"], pivot=elbow, parent=f"{s}UpperArm")
        hx, hy, hz = hand
        pieces = [mc.blob((0.36, 0.34, 0.25), hand, u=10, v=6, box=0.8)]
        for dx in (-0.17, 0.0, 0.17):
            pieces.append(mc.capsule((hx + dx, hy - 0.15, hz - 0.02), (hx + dx * 1.2, hy - 0.42, hz - 0.06),
                                     0.1, 0.085, u=6, v=4))
        thumb_x = hx - side * 0.3  # thumb on the inner side
        pieces.append(mc.capsule((thumb_x, hy + 0.05, hz + 0.08), (thumb_x - side * 0.08, hy - 0.18, hz + 0.22),
                                 0.11, 0.085, u=6, v=4))
        rig.part(f"{s}Hand", pieces, M["skin"], pivot=wrist, parent=f"{s}LowerArm")

    arm(-1, (-1.0, -0.05, 2.25), (-1.3, -0.8, 2.3), (-1.25, -1.55, 2.45), (-1.25, -1.92, 2.5))
    arm(+1, (1.0, -0.05, 2.2), (1.3, -0.7, 1.95), (1.3, -1.45, 1.95), (1.32, -1.82, 1.9))

    # ---------------- legs: short stubs + rounded toy feet
    for side in (-1, 1):
        s = "Right" if side < 0 else "Left"
        hip, ankle = (side * 0.55, 0, 1.15), (side * 0.6, -0.05, 0.4)
        rig.part(f"{s}Leg", mc.capsule(hip, ankle, 0.36, 0.32, u=10, v=6), M["skin"], pivot=hip, parent="Body")
        rig.part(f"{s}Foot", mc.blob((0.38, 0.52, 0.22), (side * 0.62, -0.2, 0.22), u=10, v=8, box=0.7),
                 M["dark"], pivot=ankle, parent=f"{s}Leg")
    return scene, rig


def main():
    scene, rig = build()
    stats = mc.mesh_stats(rig, "A_MunchieRound", {
        "colorsHex": {"skin": "#77CA63", "belly": "#59C9BE", "bib": "#EF5A4C", "eyes/teeth": "#FFFFFF",
                      "pupils/mouth/hair/feet": "#233142"},
        "uniqueMotif": "tomato napkin bib (hungry eater), single hair curl",
        "script": "tools/asset_generation/build_munchie_a.py",
    })
    height = stats["sizeStuds_WxDxH"][2]
    renders = mc.standard_previews(scene, rig, os.path.join(ROOT, "art", "renders", "munchie"), "A", height)
    stats["renders"] = {k: os.path.relpath(v, ROOT).replace("\\", "/") for k, v in renders.items()}
    blend = os.path.join(ROOT, "art", "source", "Zombie_Munchie_A.blend")
    mc.save_blend(blend)
    stats["sourceFile"] = "art/source/Zombie_Munchie_A.blend"
    mc.write_json(os.path.join(ROOT, "art", "qa", "Zombie_Munchie_A_stats.json"), stats)
    print("DTP_RESULT", stats["variant"], "tris", stats["totalTriangles"], "size", stats["sizeStuds_WxDxH"])


if __name__ == "__main__":
    main()
