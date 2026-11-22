#!/usr/bin/env python3
"""Static P0 contract checks. This is NOT a Luau compiler or a Studio play test.

The test catches accidental regressions in approved Place scope, client/server
authority, hit controls, and server-side analytics between manual Studio QA runs.
"""
import json
from pathlib import Path

root = Path(__file__).resolve().parent.parent
project = json.loads((root / "default.project.json").read_text(encoding="utf-8"))
server = (root / "src/server/MunchieP0.server.luau").read_text(encoding="utf-8")
client = (root / "src/client/SpatulaP0.client.luau").read_text(encoding="utf-8")
config = (root / "src/shared/Config.luau").read_text(encoding="utf-8")

approved_place_id = 122513508386436
assert project.get("servePlaceIds") == [approved_place_id], (
    "Rojo must sync only to approved Defend The Pizza Place"
)
assert f"ApprovedPlaceId = {approved_place_id}" in config
assert "game.PlaceId ~= Config.ApprovedPlaceId" in server
assert "game.PlaceId ~= Config.ApprovedPlaceId" in client

# Server must never trust a requested target, damage amount, or client timestamp.
assert "SpatulaSwingRequest" in server and "SpatulaSwingRequest" in client
assert "request:FireServer()" in client
assert "FireServer(" not in client.replace("request:FireServer()", "")
assert "swingRequest.OnServerEvent:Connect(function(player: Player)" in server
assert "C.SwingCooldownSeconds" in server
assert "C.SwingRangeStuds" in server
assert "C.SwingHalfAngleDegrees" in server
assert "Workspace:Raycast" in server
assert "root:SetNetworkOwner(nil)" in server
assert 'm.state = "Stunned"' in server
assert 'm.state = "Launched"' in server
assert "ApplyImpulse" in server

assert "MunchieHealth = 2" in config, "P0 Munchie has 2 hits"
assert "PizzaSlices = 8" in config
assert "PizzaBiteSeconds = 2.5" in config
assert 'analytics(player, "DTP_SpatulaHitValidated")' in server
assert 'analytics(player, "DTP_MunchieLaunched")' in server
assert 'onboarding(player, 2, "FirstAttackValidated")' in server
assert 'onboarding(player, 3, "FirstKnockback")' in server

# Neither P0 script may create purchases or unlock monetization.
for path, source in (("server", server), ("client", client)):
    for forbidden in ("MarketplaceService", "PromptProductPurchase", "ProcessReceipt"):
        assert forbidden not in source, f"{path} unexpectedly contains {forbidden}"

assert "Enum.UserInputType.MouseButton1" in client
assert "Enum.KeyCode.ButtonR2" in client
assert 'ContextActionService:SetTitle("DTP_P0_HIT", "HIT")' in client

print("OK: static P0 contract/Place/authority checks passed.")
print("NOT TESTED: Luau runtime, FBX/texture import, 7 animation asset IDs,")
print("server physics, multiplayer, mobile layout, Analytics events, Place save/publish.")
