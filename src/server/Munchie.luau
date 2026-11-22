-- Pure timing rules used by the server and the headless P0 checks.
local Munchie = {}

function Munchie.advance(distance, dt, now, stunUntil, blocked, nextBite, speed)
	if blocked or now < stunUntil then
		return 0, false
	end
	if distance > 4.5 then
		return math.min((speed or 10) * dt, distance - 4.45), false
	end
	return 0, now >= nextBite
end

function Munchie.hit(hp)
	local remaining = math.max(0, hp - 1)
	return remaining, if remaining == 0 then 20 else 5
end

-- Bite progress is shared per slice across all zombies; damage is applied on the
-- server at the visual bite marker, not when the chewing animation begins.
function Munchie.bite(currentBites, bitesPerSlice)
	assert(bitesPerSlice >= 1, "bitesPerSlice must be positive")
	local bites = math.min(bitesPerSlice, currentBites + 1)
	return bites, bites >= bitesPerSlice
end

return Munchie
