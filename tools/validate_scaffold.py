#!/usr/bin/env python3
"""Static verification of the repo skeleton (not a Roblox Studio gameplay test)."""
from pathlib import Path
import json

root = Path(__file__).resolve().parent.parent
required = [
    "README.md", "AGENTS.md", "CLAUDE.md", "default.project.json",
    "src/shared/Config.luau", "src/server/Bootstrap.server.luau",
    "src/client/Bootstrap.client.luau", "docs/GAME_DESIGN.md",
    "docs/ROADMAP.md", "docs/ANALYTICS_SPEC.md", "docs/QA_CHECKLIST.md",
    "docs/DECISIONS.md",
]
missing = [p for p in required if not (root / p).is_file()]
assert not missing, f"Missing required files: {missing}"
project = json.loads((root / "default.project.json").read_text(encoding="utf-8"))
assert project["name"] == "DefendThePizza"
assert project["tree"]["ReplicatedStorage"]["DTP"]["$path"] == "src/shared"
assert project["tree"]["ServerScriptService"]["DTPServer"]["$path"] == "src/server"
assert project["tree"]["StarterPlayer"]["StarterPlayerScripts"]["DTPClient"]["$path"] == "src/client"
assert "PizzaSlices = 8" in (root / "src/shared/Config.luau").read_text(encoding="utf-8")
print("OK: structure, Rojo mappings and config validated. Roblox Studio gameplay NOT tested.")
