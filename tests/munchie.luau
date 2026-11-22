local Munchie = require("../src/server/Munchie")
local Swings = require("../src/shared/SpatulaSwings")
local Config = require("../src/shared/Config")
local function expect(distance, blocked, stun, nextBite, expectedStep, expectedBite)
	local step, bite = Munchie.advance(distance, 0.2, 10, stun, blocked, nextBite)
	assert(math.abs(step - expectedStep) < 0.001 and bite == expectedBite)
end
expect(24, false, 0, 0, 2, false)
expect(24, true, 0, 0, 0, false)
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
print("Munchie: movement, shutter, stun, bite timing and both hits and three bites per shared pizza slice and the 3-swing combo rules passed")
