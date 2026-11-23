--!strict
-- Pure chef-health rules (hearts, post-hit invulnerability, DOWNED, free revive). The server applies them;
-- every function reports whether it changed anything, so duplicated bites / revives are harmless no-ops.
local Rules = {}

export type State = { hearts: number, invulnUntil: number, downed: boolean, token: number }

function Rules.new(hearts: number): State
	return { hearts = hearts, invulnUntil = 0, downed = false, token = 0 }
end

-- A valid bite removes one heart. Ignored while downed or inside the invulnerability window.
-- Returns (applied, "hit" | "downed" | "ignored").
function Rules.damage(s: State, now: number, invulnSeconds: number): (boolean, string)
	if s.downed or s.hearts <= 0 or now < s.invulnUntil then
		return false, "ignored"
	end
	s.hearts -= 1
	s.invulnUntil = now + invulnSeconds
	if s.hearts == 0 then
		s.downed = true
		s.token += 1
		return true, "downed"
	end
	return true, "hit"
end

-- Another chef, up and close enough, may revive a downed one. Nobody revives themselves.
function Rules.canRevive(downed: State, reviver: State, isOtherChef: boolean, distance: number, maxDistance: number): boolean
	return downed.downed and not reviver.downed and isOtherChef and distance <= maxDistance
end

-- Gets the chef back up (revive or the free timeout). `token` (optional) ties a timer to one specific fall.
function Rules.standUp(s: State, now: number, hearts: number, invulnSeconds: number, token: number?): boolean
	if not s.downed or (token ~= nil and token ~= s.token) then
		return false
	end
	s.downed = false
	s.hearts = hearts
	s.invulnUntil = now + invulnSeconds
	s.token += 1
	return true
end

function Rules.reset(s: State, hearts: number)
	s.hearts, s.invulnUntil, s.downed = hearts, 0, false
	s.token += 1
end

return Rules
