-- Pure timing rules used by the server and the headless P0 checks.
local Munchie = {}

function Munchie.advance(distance, dt, now, stunUntil, blocked, nextBite)
	if blocked or now < stunUntil then
		return 0, false
	end
	if distance > 4.5 then
		return math.min(10 * dt, distance - 4.45), false
	end
	return 0, now >= nextBite
end

function Munchie.hit(hp)
	local remaining = math.max(0, hp - 1)
	return remaining, if remaining == 0 then 7 else 3
end

return Munchie
