#!/usr/bin/env python3
"""Validate art tokens and asset declarations. Does NOT replace Blender/Studio QA."""
from pathlib import Path
import json
import re

root = Path(__file__).resolve().parent.parent
tokens = json.loads((root / "art" / "design_tokens.json").read_text(encoding="utf-8"))
manifest = json.loads((root / "art" / "asset_manifest.json").read_text(encoding="utf-8"))
assert tokens.get("project") == "DEFEND_THE_PIZZA_GAME"
assert manifest.get("project") == "DEFEND_THE_PIZZA_GAME"
assert tokens.get("status") == "PROPOSED_NOT_IMPLEMENTED"
colors = tokens.get("colors") or {}
assert colors and all(re.fullmatch(r"#[0-9A-Fa-f]{6}", s) for s in colors.values())
statuses = set(manifest.get("allowedStatuses") or [])
assert {"PLANNED", "BLOCKED", "APPROVED", "QA_PASS"} <= statuses

assets = manifest.get("assets") or []
assert assets
seen = set()
for a in assets:
    aid = a["id"]
    assert aid not in seen, f"Duplicated asset ID: {aid}"
    seen.add(aid)
    assert a["status"] in statuses, f"Invalid asset status: {aid}"
    if a["status"] == "PLANNED":
        assert a.get("sourceFile") is None and a.get("exportFile") is None, (
            f"PLANNED asset falsely claims created files: {aid}"
        )
    if a["status"] in {"QA_PASS", "APPROVED"}:
        source = a.get("sourceFile")
        assert source and (root / source).is_file(), f"Missing source file: {aid}"
        assert a.get("rightsVerified"), f"Unverified rights: {aid}"
        assert a.get("qaEvidence"), f"Missing QA evidence: {aid}"
        if a["type"] in {"3D_model", "3D_character", "3D_prop", "cosmetic_internal"}:
            export = a.get("exportFile")
            assert export and (root / export).is_file(), f"Missing 3D export: {aid}"

print(f"OK: {len(colors)} color tokens; {len(assets)} asset manifest entries. NOT Studio/visual QA.")
