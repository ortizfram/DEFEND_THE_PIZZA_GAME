local Munchie = require("../src/server/Munchie")
local Swings = require("../src/shared/SpatulaSwings")
local Config = require("../src/shared/Config")
local SpatulaHit = require("../src/shared/SpatulaHit")
local Ledger = require("../src/server/SliceLedger")
local ChefRules = require("../src/server/ChefRules")
local function expect(distance, blocked, stun, nextBite, expectedStep, expectedBite)
	local step, bite = Munchie.advance(distance, 0.2, 10, stun, blocked, nextBite)
	assert(math.abs(step - expectedStep) < 0.001 and bite == expectedBite)
end
expect(24, false, 0, 0, 2, false)
expect(24, true, 0, 0, 0, false)
assert(Config.P0.Walk.Rate > 0 and Config.P0.Walk.Stride >= 1)
-- Configured speed: the common zombie walks at 5 studs/s (1 stud per 0.2 s step).
local slowStep = Munchie.advance(24, 0.2, 10, 0, false, 0, Config.P0.MunchieSpeed)
assert(Config.P0.MunchieSpeed == 5 and math.abs(slowStep - 1) < 0.001)
expect(5, false, 0, 0, 0.55, false)
expect(4.45, false, 11, 0, 0, false)
expect(4.45, false, 10, 10, 0, true)
expect(4.45, false, 0, 12, 0, false)
local hp, push = Munchie.hit(2)
assert(hp == 1 and push == 5)
hp, push = Munchie.hit(hp)
assert(hp == 0 and push == 20)
local progress, eaten = Munchie.bite(0, 3)
assert(progress == 1 and not eaten)
progress, eaten = Munchie.bite(progress, 3)
assert(progress == 2 and not eaten)
progress, eaten = Munchie.bite(progress, 3)
assert(progress == 3 and eaten)
-- A second zombie's bite must advance the SAME slice, not start another one.
local shared, done = Munchie.bite(1, 3)
assert(shared == 2 and not done)
-- No extra damage can be counted beyond three bites.
assert(select(1, Munchie.bite(3, 3)) == 3)
-- Spatula combo: 1 -> 2 -> 3 -> 1, and a pause longer than 1.5 s restarts at swing 1.
local reset = Config.P0.Combo.ResetSeconds
assert(reset == 1.5 and #Swings.list == 3 and #Config.P0.Swing == 3)
local idx = Swings.nextIndex(0, -math.huge, 100, reset)
assert(idx == 1)
idx = Swings.nextIndex(idx, 100, 100.4, reset)
assert(idx == 2)
idx = Swings.nextIndex(idx, 100.4, 100.8, reset)
assert(idx == 3)
idx = Swings.nextIndex(idx, 100.8, 101.2, reset)
assert(idx == 1)
assert(Swings.nextIndex(2, 100, 101.6, reset) == 1) -- 1.6 s pause restarts
assert(Swings.nextIndex(2, 100, 101.4, reset) == 3) -- 1.4 s pause continues
-- Swing data: damage waits for the visual contact key, keys are ordered and end at rest.
for i, swing in Swings.list do
	assert(swing.impact >= 0.15 and swing.impact < swing.duration, "impact timing " .. i)
	assert(swing.keys[#swing.keys].t == swing.duration and next(swing.keys[#swing.keys].j) == nil, "ends at rest " .. i)
	local hasImpactKey = false
	for k = 2, #swing.keys do
		assert(swing.keys[k].t > swing.keys[k - 1].t, "key order " .. i)
		if math.abs(swing.keys[k].t - swing.impact) < 1e-6 then hasImpactKey = true end
	end
	assert(hasImpactKey, "impact key " .. i)
	assert(swing.trail[1] < swing.impact and swing.trail[2] > swing.impact, "trail covers impact " .. i)
end
assert(Config.P0.Combo.ServerCooldownSeconds < Config.P0.Combo.CooldownSeconds)
-- Spatula arc: chef at the origin facing -Z (lx,lz) = (0,-1). Only front targets inside reach/arc connect.
for index, style in Config.P0.Swing do
	local inFront = SpatulaHit.inArc(0, 0, 0, -1, 0, -5, style.Reach, style.ArcDeg)
	local behind = SpatulaHit.inArc(0, 0, 0, -1, 0, 1.8, style.Reach, style.ArcDeg)
	local beside = SpatulaHit.inArc(0, 0, 0, -1, 2.5, 0, style.Reach, style.ArcDeg)
	local tooFar = SpatulaHit.inArc(0, 0, 0, -1, 0, -(style.Reach + 1), style.Reach, style.ArcDeg)
	assert(inFront and not behind and not beside and not tooFar, "arc swing " .. index)
end
-- The side swing sweeps wider than the overhead: a target 50 degrees off-axis is hit only by the side swing.
local x50, z50 = 5 * math.sin(math.rad(50)), -5 * math.cos(math.rad(50))
assert(not SpatulaHit.inArc(0, 0, 0, -1, x50, z50, Config.P0.Swing[1].Reach, Config.P0.Swing[1].ArcDeg))
assert(SpatulaHit.inArc(0, 0, 0, -1, x50, z50, Config.P0.Swing[3].Reach, Config.P0.Swing[3].ArcDeg))
-- select(): nearest valid target wins; a blocked (wall) or rear target is skipped.
local front, rear, blocked = { x = 0, z = -4 }, { x = 0, z = 1 }, { x = 0, z = -3 }
local chosen = SpatulaHit.select(0, 0, 0, -1, { rear, front }, 7, 35, nil)
assert(chosen == front, "rear zombie must not be chosen")
chosen = SpatulaHit.select(0, 0, 0, -1, { blocked, front }, 7, 35, function(c) return c ~= blocked end)
assert(chosen == front, "wall-blocked zombie must be skipped")
assert(SpatulaHit.select(0, 0, 0, -1, { rear }, 7, 35, nil) == nil)
-- Contact rule: a zombie outside the arc but touched by the blade is still hit; an untouched one is not.
assert(SpatulaHit.touches(-4, 0.3, -1.6, -4.5, -2, 0, 4, Config.P0.TouchRadius))
assert(not SpatulaHit.touches(-4, 0.3, -1.6, 5, 5, 0, 4, Config.P0.TouchRadius))
local side = { x = -4.0, z = -1.6 } -- 68 degrees off-axis: outside the side swing's 65 degree arc
assert(SpatulaHit.select(0, 0, 0, -1, { side }, 8, 65, nil, nil) == nil)
assert(SpatulaHit.select(0, 0, 0, -1, { side }, 8, 65, nil, function() return true end) == side)
assert(SpatulaHit.select(0, 0, 0, -1, { rear }, 8, 65, nil, function() return false end) == nil)
for _, style in Config.P0.Swing do assert(#style.Tips >= 2) end
-- Slice Thief ledger: steal -> recover once; duplicates, second attempts and overflow are no-ops.
local L = Ledger.new()
local left, ok = Ledger.steal(L, 8)
assert(ok and left == 7 and L.carried)
local again, ok2 = Ledger.steal(L, 7)
assert(not ok2 and again == 7, "no second steal while carrying")
local back, ok3 = Ledger.recover(L, 7, 8)
assert(ok3 and back == 8 and not L.carried)
local dup, ok4 = Ledger.recover(L, 8, 8)
assert(not ok4 and dup == 8, "recovering twice must not add a ninth slice")
local _, ok5 = Ledger.steal(L, 8)
assert(not ok5, "only one steal attempt per round")
Ledger.reset(L)
left = Ledger.steal(L, 8)
assert(left == 7 and Ledger.escape(L) and L.lost == 1 and not L.carried)
assert(not Ledger.escape(L) and L.lost == 1, "loss is confirmed once")
local r1, ok6 = Ledger.recover(L, 7, 8)
assert(not ok6 and r1 == 7, "an escaped slice cannot be recovered")
Ledger.reset(L)
local none, ok7 = Ledger.steal(L, 0)
assert(not ok7 and none == 0, "nothing to steal from an empty pizza")
-- Munchie eating continues on the remaining slices after a steal.
Ledger.reset(L)
local avail = Ledger.steal(L, 8)
local progress, eaten = Munchie.bite(0, 3)
progress, eaten = Munchie.bite(progress, 3)
progress, eaten = Munchie.bite(progress, 3)
assert(eaten and avail - 1 == 6)
-- Chef hearts: 3 separated bites -> DOWNED; bites inside the invulnerability window or while down do nothing.
local chef = ChefRules.new(3)
local ok1, r1 = ChefRules.damage(chef, 10, 1.0)
assert(ok1 and r1 == "hit" and chef.hearts == 2)
assert(not ChefRules.damage(chef, 10.5, 1.0) and chef.hearts == 2, "second bite inside 1 s is ignored")
local ok2 = ChefRules.damage(chef, 11.1, 1.0)
assert(ok2 and chef.hearts == 1)
local ok3, r3 = ChefRules.damage(chef, 12.2, 1.0)
assert(ok3 and r3 == "downed" and chef.hearts == 0 and chef.downed)
assert(not ChefRules.damage(chef, 20, 1.0) and chef.hearts == 0, "no bites on a downed chef")
-- Revive: another chef, close, up; never yourself, from far away, by a downed chef, or twice.
local helper = ChefRules.new(3)
assert(not ChefRules.canRevive(chef, chef, false, 1, 9), "self revive")
assert(not ChefRules.canRevive(chef, helper, true, 30, 9), "revive from far away")
local downedHelper = ChefRules.new(3)
downedHelper.downed = true
assert(not ChefRules.canRevive(chef, downedHelper, true, 2, 9), "a downed chef cannot revive")
assert(ChefRules.canRevive(chef, helper, true, 2, 9))
local staleToken = chef.token - 1
assert(not ChefRules.standUp(chef, 30, 3, 2.0, staleToken), "a stale timer cannot stand the chef up")
assert(ChefRules.standUp(chef, 30, 3, 2.0) and not chef.downed and chef.hearts == 3)
assert(not ChefRules.standUp(chef, 30.1, 3, 2.0), "a second revive is a no-op")
assert(not ChefRules.damage(chef, 31, 1.0), "revive invulnerability")
assert(ChefRules.damage(chef, 32.1, 1.0), "bites work again after the grace period")
assert(not ChefRules.canRevive(chef, helper, true, 2, 9), "an up chef cannot be revived")
ChefRules.reset(chef, 3)
assert(chef.hearts == 3 and not chef.downed and chef.invulnUntil == 0)
assert(Config.P0.Chef.DownedMaxSeconds <= 12 and Config.P0.Chef.ReviveSeconds == 2 and Config.P0.Chef.Hearts == 3)
print("Munchie: movement, shutter, stun, bite timing and both hits and three bites per shared pizza slice and the 3-swing combo rules and spatula arc/reach selection passed")
