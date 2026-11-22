-- DTP-3D-003 Zombie Munchie A — 7 blockout animations as KeyframeSequences.
-- Run in Roblox Studio (Edit) AFTER tools/studio/rig_munchie_a.luau.
-- Creates ServerStorage.RBX_ANIMSAVES.Zombie_Munchie_A.<Name> so the Animation Editor can open,
-- polish and publish them. Publishing (asset upload) is a manual owner step; nothing is uploaded here.
--
-- Joint frames follow the standard Roblox character frame: the rig faces -Z, +X = character right, +Y up.
--   rx > 0 : head/torso tilt BACK, forward-pointing arms RAISE, hanging legs swing FORWARD
--   ry     : right arm out = negative, left arm out = positive (arms rest pointing forward)
--   rz     : right leg out = positive, left leg out = negative
-- Timings are P0 hypotheses from docs/COMBAT_PHYSICS_ANIMATION_V04.md (telegraph 0.4 s, etc.).
-- Defeat root offsets were settled in Studio by raycast so the body rests on the floor (2026-11-22).
-- PREVIEW CAVEAT (verified 2026-11-22): previewing with Animator:StepAnimations in Edit mode leaves an
-- internal pose in the Motor6Ds that survives Stop()/Transform resets. Preview in the Animation Editor or
-- in Play mode. If a rig gets stuck, anchor parts, re-solve from C0/C1 and recreate the Motor6Ds.
-- Gameplay must never depend on markers alone: the server decides damage (AGENTS.md rule 5).

local MODEL_NAME = "Zombie_Munchie_A"

-- joint (Motor6D) name -> Part1 name; tree used to nest Pose instances
local PART_OF = {
	Root = "Body", Neck = "Head",
	RightShoulder = "RightUpperArm", RightElbow = "RightLowerArm", RightWrist = "RightHand",
	LeftShoulder = "LeftUpperArm", LeftElbow = "LeftLowerArm", LeftWrist = "LeftHand",
	RightHip = "RightLeg", RightAnkle = "RightFoot", LeftHip = "LeftLeg", LeftAnkle = "LeftFoot",
}
local TREE = {
	HumanoidRootPart = { "Body" },
	Body = { "Head", "RightUpperArm", "LeftUpperArm", "RightLeg", "LeftLeg" },
	RightUpperArm = { "RightLowerArm" }, RightLowerArm = { "RightHand" },
	LeftUpperArm = { "LeftLowerArm" }, LeftLowerArm = { "LeftHand" },
	RightLeg = { "RightFoot" }, LeftLeg = { "LeftFoot" },
}

local function R(rx: number?, ry: number?, rz: number?, px: number?, py: number?, pz: number?): CFrame
	return CFrame.new(px or 0, py or 0, pz or 0)
		* CFrame.Angles(math.rad(rx or 0), math.rad(ry or 0), math.rad(rz or 0))
end

type Key = { t: number, pose: { [string]: CFrame }, style: Enum.PoseEasingStyle? }
type Anim = { name: string, loop: boolean, priority: Enum.AnimationPriority, keys: { Key }, markers: { { string } }? }

local NEUTRAL = {}
local ANIMS: { Anim } = {
	{
		name = "Idle", loop = true, priority = Enum.AnimationPriority.Idle,
		keys = {
			{ t = 0, pose = { Root = R(0, 0, 0, 0, 0, 0), Neck = R(-3, 0, -5), RightShoulder = R(4), LeftShoulder = R(-4) } },
			{ t = 0.8, pose = { Root = R(0, 0, 0, 0, -0.05, 0), Neck = R(4, 0, 6), RightShoulder = R(-6), LeftShoulder = R(8), RightWrist = R(0, 0, 8), LeftWrist = R(0, 0, -8) } },
			{ t = 1.6, pose = { Root = R(0, 0, 0, 0, 0, 0), Neck = R(-3, 0, -5), RightShoulder = R(4), LeftShoulder = R(-4) } },
		},
	},
	{
		name = "Walk", loop = true, priority = Enum.AnimationPriority.Movement,
		markers = { { "Footstep", "0" }, { "Footstep", "0.4" } },
		keys = {
			{ t = 0, pose = { Root = R(0, 8, 6, 0, -0.06, 0), RightHip = R(25), LeftHip = R(-22), RightShoulder = R(14, 0, 0), LeftShoulder = R(2), Neck = R(-5, -6, -4) } },
			{ t = 0.2, pose = { Root = R(0, 0, 0, 0, 0.12, 0), RightHip = R(0), LeftHip = R(0), RightShoulder = R(8), LeftShoulder = R(8), Neck = R(4) } },
			{ t = 0.4, pose = { Root = R(0, -8, -6, 0, -0.06, 0), RightHip = R(-22), LeftHip = R(25), RightShoulder = R(2), LeftShoulder = R(14), Neck = R(-5, 6, 4) } },
			{ t = 0.6, pose = { Root = R(0, 0, 0, 0, 0.12, 0), RightHip = R(0), LeftHip = R(0), RightShoulder = R(8), LeftShoulder = R(8), Neck = R(4) } },
			{ t = 0.8, pose = { Root = R(0, 8, 6, 0, -0.06, 0), RightHip = R(25), LeftHip = R(-22), RightShoulder = R(14, 0, 0), LeftShoulder = R(2), Neck = R(-5, -6, -4) } },
		},
	},
	{
		name = "PizzaBite", loop = false, priority = Enum.AnimationPriority.Action,
		markers = { { "Bite", "0.55" } },
		keys = {
			{ t = 0, pose = NEUTRAL },
			{ t = 0.35, pose = { Root = R(8), Neck = R(18), RightShoulder = R(30), LeftShoulder = R(30) } },
			{ t = 0.55, pose = { Root = R(-24, 0, 0, 0, -0.1, -0.2), Neck = R(-22), RightShoulder = R(-25), LeftShoulder = R(-25), RightWrist = R(-20), LeftWrist = R(-20) }, style = Enum.PoseEasingStyle.Linear },
			{ t = 0.9, pose = NEUTRAL },
		},
	},
	{
		name = "AttackChef", loop = false, priority = Enum.AnimationPriority.Action2,
		markers = { { "HitWindow", "0.5" } },
		keys = {
			{ t = 0, pose = NEUTRAL },
			{ t = 0.4, pose = { Root = R(8, 0, 0, 0, 0, 0.15), Neck = R(12), RightShoulder = R(25, -35), LeftShoulder = R(25, 35), RightWrist = R(0, 0, 20), LeftWrist = R(0, 0, -20) } },
			{ t = 0.55, pose = { Root = R(-16, 0, 0, 0, -0.05, -0.6), Neck = R(-18), RightShoulder = R(6, 10), LeftShoulder = R(6, -10), RightHip = R(-15), LeftHip = R(20) }, style = Enum.PoseEasingStyle.Linear },
			{ t = 1.2, pose = NEUTRAL },
		},
	},
	{
		name = "HitReaction", loop = false, priority = Enum.AnimationPriority.Action3,
		keys = {
			{ t = 0, pose = NEUTRAL },
			{ t = 0.08, pose = { Root = R(22, 0, 0, 0, -0.25, 0.3), Neck = R(30, 0, 8), RightShoulder = R(55, -20), LeftShoulder = R(55, 20), RightHip = R(15), LeftHip = R(15) }, style = Enum.PoseEasingStyle.Linear },
			{ t = 0.22, pose = { Root = R(-6, 0, 0, 0, 0.05, 0.1), Neck = R(-10, 0, -6), RightShoulder = R(10), LeftShoulder = R(10) }, style = Enum.PoseEasingStyle.Elastic },
			{ t = 0.45, pose = NEUTRAL },
		},
	},
	{
		name = "Knockback", loop = true, priority = Enum.AnimationPriority.Action4,
		keys = {
			{ t = 0, pose = { Neck = R(22), RightShoulder = R(40, -70), LeftShoulder = R(40, 70), RightElbow = R(0, -10), LeftElbow = R(0, 10), RightHip = R(10, 0, 25), LeftHip = R(10, 0, -25) } },
			{ t = 0.25, pose = { Neck = R(28, 0, 6), RightShoulder = R(55, -80), LeftShoulder = R(55, 80), RightElbow = R(0, 10), LeftElbow = R(0, -10), RightHip = R(-5, 0, 32), LeftHip = R(-5, 0, -32) } },
			{ t = 0.5, pose = { Neck = R(22), RightShoulder = R(40, -70), LeftShoulder = R(40, 70), RightElbow = R(0, -10), LeftElbow = R(0, 10), RightHip = R(10, 0, 25), LeftHip = R(10, 0, -25) } },
		},
	},
	{
		name = "Defeat", loop = false, priority = Enum.AnimationPriority.Action4,
		markers = { { "Despawn", "0.8" } },
		keys = {
			{ t = 0, pose = NEUTRAL },
			{ t = 0.35, pose = { Root = R(85, 0, 0, 0, 0.25, 0.9), Neck = R(-15), RightShoulder = R(20, -75), LeftShoulder = R(20, 75), RightHip = R(55, 0, 15), LeftHip = R(55, 0, -15) }, style = Enum.PoseEasingStyle.Bounce },
			{ t = 0.8, pose = { Root = R(88, 0, 0, 0, 0.15, 0.95), Neck = R(-20, 0, 15), RightShoulder = R(10, -85), LeftShoulder = R(10, 85), RightHip = R(40, 0, 20), LeftHip = R(40, 0, -20) } },
		},
	},
}

local partToJoint = {}
for joint, part in PART_OF do
	partToJoint[part] = joint
end

local function buildPose(partName: string, pose: { [string]: CFrame }, style: Enum.PoseEasingStyle): Pose
	local p = Instance.new("Pose")
	p.Name = partName
	local joint = partToJoint[partName]
	p.CFrame = joint and pose[joint] or CFrame.identity
	p.Weight = partName == "HumanoidRootPart" and 0 or 1
	p.EasingStyle = style
	p.EasingDirection = Enum.PoseEasingDirection.InOut
	for _, child in TREE[partName] or {} do
		buildPose(child, pose, style).Parent = p
	end
	return p
end

local function buildSequence(a: Anim): KeyframeSequence
	local ks = Instance.new("KeyframeSequence")
	ks.Name = a.name
	ks.Loop = a.loop
	ks.Priority = a.priority
	for _, k in a.keys do
		local kf = Instance.new("Keyframe")
		kf.Time = k.t
		buildPose("HumanoidRootPart", k.pose, k.style or Enum.PoseEasingStyle.Cubic).Parent = kf
		kf.Parent = ks
	end
	for _, m in a.markers or {} do
		local t = tonumber(m[2]) :: number
		local target: Keyframe? = nil
		for _, kf in ks:GetChildren() do
			if kf:IsA("Keyframe") and math.abs(kf.Time - t) < 1e-3 then
				target = kf
			end
		end
		if not target then
			local kf = Instance.new("Keyframe")
			kf.Time = t
			kf.Parent = ks
			target = kf
		end
		local marker = Instance.new("KeyframeMarker")
		marker.Name = m[1]
		marker.Value = a.name
		marker.Parent = target
	end
	return ks
end

local ServerStorage = game:GetService("ServerStorage")
local saves = ServerStorage:FindFirstChild("RBX_ANIMSAVES") or Instance.new("Folder")
saves.Name = "RBX_ANIMSAVES"
saves.Parent = ServerStorage
local folder = saves:FindFirstChild(MODEL_NAME)
if folder then
	folder:Destroy() -- rebuilt from this file (source of truth)
end
folder = Instance.new("ObjectValue")
folder.Name = MODEL_NAME
folder.Value = workspace:FindFirstChild(MODEL_NAME)
folder.Parent = saves

local summary = {}
for _, a in ANIMS do
	local ks = buildSequence(a)
	ks.Parent = folder
	table.insert(summary, string.format("%s %.2fs loop=%s", a.name, a.keys[#a.keys].t, tostring(a.loop)))
end
game:GetService("ChangeHistoryService"):SetWaypoint("DTP: build Munchie A animations")
return summary
