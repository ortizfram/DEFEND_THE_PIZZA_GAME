--!strict
-- Pure targeting maths for the spatula (numbers only, so CI can test it without Roblox types).
-- A swing reaches a zombie only inside a frontal arc and a maximum reach measured on the ground plane.
-- Walls/doors are handled by the server with a ray (see Bootstrap.server.luau); this file never decides damage.
local Hit = {}

-- true when the point (px,pz) lies within `reach` of (ox,oz) and within +-halfArcDeg of the facing (lx,lz).
function Hit.inArc(ox: number, oz: number, lx: number, lz: number, px: number, pz: number, reach: number, halfArcDeg: number): (boolean, number)
	local dx, dz = px - ox, pz - oz
	local dist = math.sqrt(dx * dx + dz * dz)
	if dist > reach then
		return false, dist
	end
	if dist < 0.05 then
		return true, dist -- standing inside the target
	end
	local lm = math.sqrt(lx * lx + lz * lz)
	if lm < 1e-4 then
		return false, dist
	end
	local cosine = (lx * dx + lz * dz) / (lm * dist)
	return cosine >= math.cos(math.rad(halfArcDeg)), dist
end

-- true when the point (tx,ty,tz) is within `radius` of the vertical body segment at (px,pz) spanning y0..y1.
function Hit.touches(tx: number, ty: number, tz: number, px: number, pz: number, y0: number, y1: number, radius: number): boolean
	local dx, dz = tx - px, tz - pz
	local dy = math.max(y0 - ty, 0, ty - y1)
	return dx * dx + dz * dz + dy * dy <= radius * radius
end

-- Closest candidate that is inside the arc and passes the optional `clear` check (line of sight).
-- Each candidate needs numeric x and z fields.
function Hit.select(ox: number, oz: number, lx: number, lz: number, candidates: { any }, reach: number, halfArcDeg: number, clear: ((any) -> boolean)?, touch: ((any) -> boolean)?): any?
	local best, bestDist = nil, math.huge
	for _, c in candidates do
		local ok, dist = Hit.inArc(ox, oz, lx, lz, c.x, c.z, reach, halfArcDeg)
		if not ok and touch ~= nil and dist <= reach + 4 and touch(c) then
			ok = true -- blade contact counts even outside the arc
		end
		if ok and dist < bestDist and (clear == nil or clear(c)) then
			best, bestDist = c, dist
		end
	end
	return best
end

return Hit
