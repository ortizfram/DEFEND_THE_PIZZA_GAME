--!strict
-- DTP-3D-003 Zombie Munchie A — simple rigid Motor6D rig (no skinning).
-- Run in Roblox Studio (Edit) on a model imported from art/export/Zombie_Munchie_A.fbx
-- with Importer options: "Fijar pivote a origen de escena" ON (pivot = Blender origin at the feet).
--
-- Blender -> Roblox axis mapping verified in Studio 2026-11-22 (FBX, Forward Z / Up Y, FBX Unit Scale):
--   local Roblox = (-bx, bz, by)   [Blender +X (character left) -> Roblox -X, Blender -Y (front) -> Roblox -Z]
-- Joint coordinates come from art/qa/Zombie_Munchie_A_stats.json (part pivots, Blender studs).
--
-- Result: HumanoidRootPart (anchored, simple collision box) + Humanoid/Animator + 12 Motor6D
-- (Root + 11 joints); facial/belly details welded to their segment; mesh parts CanCollide=false.
-- This builds the RIG only. It does not animate and contains no NPC AI or gameplay.

local CHS = game:GetService("ChangeHistoryService")
local model = workspace:FindFirstChild("Zombie_Munchie_A") :: Model
assert(model, "Zombie_Munchie_A not found in Workspace")
assert(not model:FindFirstChild("HumanoidRootPart"), "Model already rigged")

local origin = model:GetPivot() -- Blender origin (feet centre) in world space
local function J(bx: number, by: number, bz: number): CFrame
	return origin * CFrame.new(-bx, bz, by)
end

local parts: { [string]: BasePart } = {}
for _, d in model:GetDescendants() do
	if d:IsA("BasePart") then
		parts[d.Name] = d
	end
end
local before: { [string]: CFrame } = {}
for name, p in parts do
	before[name] = p.CFrame
end

-- flatten hierarchy: every part a direct child of the model
for _, p in parts do
	p.Parent = model
end

-- root part: hips at 1.15 studs -> HipHeight 1.15
local hrp = Instance.new("Part")
hrp.Name = "HumanoidRootPart"
hrp.Size = Vector3.new(2.4, 2.4, 2.0)
hrp.CFrame = origin * CFrame.new(0, 1.15 + 1.2, 0)
hrp.Transparency = 1
hrp.Anchored = true
hrp.CanCollide = true
hrp.Parent = model
model.PrimaryPart = hrp

local function motor(name: string, p0: BasePart, p1: BasePart, joint: CFrame)
	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = p0
	m.Part1 = p1
	m.C0 = p0.CFrame:ToObjectSpace(joint)
	m.C1 = p1.CFrame:ToObjectSpace(joint)
	m.Parent = p1
end

local P = parts
motor("Root", hrp, P.Body, J(0, 0, 1.15))
motor("Neck", P.Body, P.Head, J(0, -0.05, 2.55))
motor("RightShoulder", P.Body, P.RightUpperArm, J(-1.0, -0.05, 2.25))
motor("RightElbow", P.RightUpperArm, P.RightLowerArm, J(-1.3, -0.8, 2.3))
motor("RightWrist", P.RightLowerArm, P.RightHand, J(-1.25, -1.55, 2.45))
motor("LeftShoulder", P.Body, P.LeftUpperArm, J(1.0, -0.05, 2.2))
motor("LeftElbow", P.LeftUpperArm, P.LeftLowerArm, J(1.3, -0.7, 1.95))
motor("LeftWrist", P.LeftLowerArm, P.LeftHand, J(1.3, -1.45, 1.95))
motor("RightHip", P.Body, P.RightLeg, J(-0.62, 0, 1.15))
motor("RightAnkle", P.RightLeg, P.RightFoot, J(-0.7, -0.05, 0.4))
motor("LeftHip", P.Body, P.LeftLeg, J(0.62, 0, 1.15))
motor("LeftAnkle", P.LeftLeg, P.LeftFoot, J(0.7, -0.05, 0.4))

-- details follow their segment
local details = {
	Body = { "Belly", "Bib" },
	Head = { "Eye_L", "Eye_R", "Pupils", "Mouth", "Teeth", "Tongue", "Hair" },
}
for seg, list in details do
	for _, n in list do
		local w = Instance.new("WeldConstraint")
		w.Name = "Weld_" .. n
		w.Part0 = P[seg]
		w.Part1 = P[n]
		w.Parent = P[n]
		P[n].Massless = true
	end
end

for _, p in parts do
	p.Anchored = false
	p.CanCollide = false -- collision = HumanoidRootPart box only (Art Bible: simple invisible collision)
	p.CanTouch = false
	p.CanQuery = true -- spatial queries (spatula hit detection) can still find limbs
end

local hum = Instance.new("Humanoid")
hum.RigType = Enum.HumanoidRigType.R15
hum.HipHeight = 1.15
hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
hum.Parent = model
Instance.new("Animator").Parent = hum

-- verification: nothing moved, everything connected to the root
local maxDrift = 0
for name, p in parts do
	maxDrift = math.max(maxDrift, (p.Position - before[name].Position).Magnitude)
end
local connected = #hrp:GetConnectedParts(true)

local function count(cls: string): number
	local n = 0
	for _, d in model:GetDescendants() do
		if d:IsA(cls) then
			n += 1
		end
	end
	return n
end

CHS:SetWaypoint("DTP: rig Zombie_Munchie_A (Motor6D)")
return {
	motors = count("Motor6D"),
	welds = count("WeldConstraint"),
	connectedToRoot = connected,
	totalParts = count("BasePart"),
	maxDriftStuds = maxDrift,
}
