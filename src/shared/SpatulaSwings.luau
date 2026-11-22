--!strict
-- Data-driven spatula swings + combo rule. Pure: no Roblox services, so CI can test nextIndex.
-- Joint angles are degrees {rx, ry, rz, dx, dy, dz} applied to Motor6D.Transform of the R15 character.
-- Conventions (character faces -Z, +X is its right):
--   arm/leg/shoulder rx > 0 swings FORWARD/UP, torso rx > 0 leans BACK, ry > 0 turns LEFT, rz > 0 raises right arm sideways.
--   Grip rx = -90 aligns the spatula with the forearm; other values tilt it (see per-swing notes).
--   Tuned in Studio 2026-11-22 on the AnimationConstraint R15: blade tip at impact ~4-5 studs in front of the
--   root at lower-body (overhead), mid-body (uppercut) and mid/upper-body (side) height, never under the floor.
-- A joint missing from a key eases back to rest (identity). `ease` applies to the segment ENDING at that key.
-- Gameplay never trusts this file's timings on the client: the server schedules damage at `impact`.
local Swings = {}

Swings.MOTOR_NAMES = {
	Root = "RootJoint", Waist = "Waist", Neck = "Neck",
	RShoulder = "RightShoulder", RElbow = "RightElbow", RWrist = "RightWrist",
	LShoulder = "LeftShoulder", LElbow = "LeftElbow",
	RHip = "RightHip", LHip = "LeftHip", RKnee = "RightKnee", LKnee = "LeftKnee",
	Grip = "SpatulaGrip",
}

export type Key = { t: number, ease: string?, j: { [string]: { number } } }
export type Swing = {
	name: string, duration: number, impact: number, trail: { number }, whoosh: number,
	pitch: number, color: Color3?, keys: { Key }, [string]: any,
}

Swings.list = {
	-- 1 OVERHEAD SLAM: spatula high over the head, lean back, then a fast heavy chop down with a knee-bend crash.
	{
		name = "OverheadSlam", duration = 0.58, impact = 0.27, trail = { 0.17, 0.36 }, whoosh = 0.15, pitch = 0.9,
		keys = {
			{ t = 0, j = {} },
			{ t = 0.16, ease = "Out", j = {
				RShoulder = { 168, -8, 12 }, RElbow = { 35 }, RWrist = { -15 }, Grip = { -70 },
				LShoulder = { 45, 0, -14 }, Waist = { 15 }, Neck = { -10 }, Root = { 0, 0, 0, 0, 0.04, 0.05 },
				RKnee = { -8 }, LKnee = { -8 },
			} },
			{ t = 0.27, ease = "In", j = {
				RShoulder = { 40, 3, -2 }, RElbow = { 12 }, RWrist = { 10 }, Grip = { -30 },
				LShoulder = { 20, 0, -20 }, Waist = { -28 }, Neck = { 16 }, Root = { 0, 0, 0, 0, -0.38, -0.12 },
				RHip = { 22 }, LHip = { 22 }, RKnee = { -38 }, LKnee = { -38 },
			} },
			{ t = 0.34, ease = "Out", j = {
				RShoulder = { 30, 4, 6 }, RElbow = { 20 }, Grip = { -30 },
				LShoulder = { 15, 0, -16 }, Waist = { -32 }, Neck = { 18 }, Root = { 0, 0, 0, 0, -0.42, -0.14 },
				RHip = { 24 }, LHip = { 24 }, RKnee = { -42 }, LKnee = { -42 },
			} },
			{ t = 0.58, ease = "InOut", j = {} },
		},
	},
	-- 2 UPPERCUT: spatula scooped low beside the floor with a crouch, then an explosive rising arc with a body arch.
	{
		name = "Uppercut", duration = 0.54, impact = 0.23, trail = { 0.13, 0.33 }, whoosh = 0.12, pitch = 1.15,
		keys = {
			{ t = 0, j = {} },
			{ t = 0.14, ease = "Out", j = {
				RShoulder = { -35, 10, -6 }, RElbow = { 10 }, RWrist = { 8 }, Grip = { 12 },
				LShoulder = { -25, 0, -12 }, Waist = { -24, -12, 0 }, Neck = { 12 }, Root = { 0, 0, 0, 0, -0.42, -0.1 },
				RHip = { 30 }, LHip = { 30 }, RKnee = { -46 }, LKnee = { -46 },
			} },
			{ t = 0.23, ease = "In", j = {
				RShoulder = { 45, -6, -2 }, RElbow = { 14 }, RWrist = { -8 }, Grip = { -75 },
				LShoulder = { 30, 0, -22 }, Waist = { 12, 8, 0 }, Neck = { -10 }, Root = { 0, 0, 0, 0, 0.1, 0.05 },
				RHip = { 4 }, LHip = { 4 }, RKnee = { -6 }, LKnee = { -6 },
			} },
			{ t = 0.31, ease = "Out", j = {
				RShoulder = { 115, -4, 4 }, RElbow = { 24 }, Grip = { -60 },
				LShoulder = { 40, 0, -26 }, Waist = { 20, 10, 0 }, Neck = { -14 }, Root = { 0, 0, 0, 0, 0.14, 0.08 },
				RHip = { -4 }, LHip = { -4 },
			} },
			{ t = 0.54, ease = "InOut", j = {} },
		},
	},
	-- 3 SIDE SWING: spatula out to the right, torso and shoulders twisted right, then a flat horizontal sweep to the centre.
	{
		name = "SideSwing", duration = 0.5, impact = 0.2, trail = { 0.1, 0.3 }, whoosh = 0.09, pitch = 1.0,
		keys = {
			{ t = 0, j = {} },
			{ t = 0.13, ease = "Out", j = {
				RShoulder = { 6, -52, 86 }, RElbow = { 12 }, Grip = { -90 },
				LShoulder = { 18, 0, -18 }, Waist = { 2, -42, 0 }, Neck = { 0, 28, 0 }, Root = { 0, -10, 0, 0, -0.14, 0 },
				RKnee = { -14 }, LKnee = { -14 }, RHip = { 8 }, LHip = { 8 },
			} },
			{ t = 0.2, ease = "In", j = {
				RShoulder = { 6, 38, 76 }, RElbow = { 8 }, Grip = { -90 },
				LShoulder = { 30, 0, -30 }, Waist = { -2, 34, 0 }, Neck = { 0, -20, 0 }, Root = { 0, 14, 0, 0, -0.1, 0 },
				RKnee = { -12 }, LKnee = { -12 }, RHip = { 6 }, LHip = { 6 },
			} },
			{ t = 0.28, ease = "Out", j = {
				RShoulder = { 6, 88, 74 }, RElbow = { 14 }, Grip = { -90 },
				LShoulder = { 34, 0, -34 }, Waist = { -2, 42, 0 }, Neck = { 0, -28, 0 }, Root = { 0, 20, 0, 0, -0.08, 0 },
				RKnee = { -10 }, LKnee = { -10 }, RHip = { 5 }, LHip = { 5 },
			} },
			{ t = 0.5, ease = "InOut", j = {} },
		},
	},
}

-- Combo: 1 -> 2 -> 3 -> 1 ... ; any pause longer than resetAfter restarts at 1.
function Swings.nextIndex(previous: number, lastAt: number, now: number, resetAfter: number): number
	if previous < 1 or now - lastAt > resetAfter then
		return 1
	end
	return previous % #Swings.list + 1
end

local function ease(kind: string?, a: number): number
	if kind == "In" then
		return a * a
	elseif kind == "Out" then
		return 1 - (1 - a) * (1 - a)
	elseif kind == "InOut" then
		return a * a * (3 - 2 * a)
	end
	return a
end

local function toCFrame(p: { number }): CFrame
	return CFrame.new(p[4] or 0, p[5] or 0, p[6] or 0)
		* CFrame.Angles(math.rad(p[1] or 0), math.rad(p[2] or 0), math.rad(p[3] or 0))
end

-- Joint names a swing drives (union over keys), cached on the swing table.
function Swings.joints(swing: Swing): { string }
	if not swing._joints then
		local seen, list = {}, {}
		for _, key in swing.keys do
			for name in key.j do
				if not seen[name] then
					seen[name] = true
					table.insert(list, name)
				end
			end
		end
		swing._joints = list
	end
	return swing._joints
end

-- Pose (joint name -> CFrame) at time t. `start` = joint CFrames when the swing began, so a new
-- swing started during the previous recovery blends instead of snapping.
function Swings.evaluate(swing: Swing, t: number, start: { [string]: CFrame }?): { [string]: CFrame }
	if not swing._cf then
		local cache = {}
		for i, key in swing.keys do
			cache[i] = {}
			for name, p in key.j do
				cache[i][name] = toCFrame(p)
			end
		end
		swing._cf = cache
	end
	local keys, cache = swing.keys, swing._cf
	local i = #keys
	for n = 2, #keys do
		if t <= keys[n].t then
			i = n
			break
		end
	end
	local a = math.clamp((t - keys[i - 1].t) / (keys[i].t - keys[i - 1].t), 0, 1)
	a = ease(keys[i].ease, a)
	local pose = {}
	for _, name in Swings.joints(swing) do
		local from = if i == 2 then (start and start[name]) or CFrame.identity else cache[i - 1][name] or CFrame.identity
		pose[name] = from:Lerp(cache[i][name] or CFrame.identity, a)
	end
	return pose
end

return Swings
