--!strict
-- Client-side spatula swing playback: joint poses, blade trail, whoosh, impact spark/shake.
-- Purely visual. The server owns combo order, hit validation, timing of damage and knockback.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("DTP")
local Swings = require(shared:WaitForChild("SpatulaSwings"))
local config = require(shared:WaitForChild("Config"))

local localPlayer = Players.LocalPlayer
local SwingPlayer = {}

-- Audio: files that ship with the Roblox client (no uploads, no third-party assets).
-- PLACEHOLDER quality: pitch-shifted stock sounds, need a listening pass by the owner.
local WHOOSH = "rbxasset://sounds/action_jump.mp3"
local IMPACT = "rbxasset://sounds/impact_explosion_03.mp3"
local TRAIL_COLORS = { Color3.fromRGB(255, 192, 67), Color3.fromRGB(89, 201, 190), Color3.fromRGB(255, 247, 231) }

type Active = { swing: any, t0: number, start: { [string]: CFrame }, motors: { [string]: any }, trail: Trail? }
local active: { [Model]: Active } = {}
local localIndex, localAt, localCooldownUntil = 0, -math.huge, 0

-- Joints expose .Transform in both rig flavours: classic Motor6D (RootJoint) and the newer
-- AnimationConstraint R15 (Root). Verified in Studio 2026-11-22: this place spawns the latter.
local function motorsOf(character: Model): { [string]: any }
	local byName = {}
	for _, item in character:GetDescendants() do
		if item:IsA("Motor6D") or item:IsA("AnimationConstraint") then byName[item.Name] = item end
	end
	byName.RootJoint = byName.RootJoint or byName.Root
	local out = {}
	for key, motorName in Swings.MOTOR_NAMES do
		if byName[motorName] then out[key] = byName[motorName] end
	end
	return out
end

local function sound(parent: Instance, id: string, speed: number, volume: number, life: number)
	local s = Instance.new("Sound")
	s.SoundId, s.PlaybackSpeed, s.Volume = id, speed, volume
	s.RollOffMaxDistance = 80
	s.Parent = parent
	s:Play()
	Debris:AddItem(s, life)
end

local function finish(character: Model, a: Active)
	for _, motor in a.motors do motor.Transform = CFrame.identity end
	if a.trail then a.trail.Enabled = false end
	active[character] = nil
end

function SwingPlayer.play(character: Model, index: number)
	local swing = Swings.list[index]
	if not swing then return end
	local previous = active[character]
	local motors = if previous then previous.motors else motorsOf(character)
	if not motors.RShoulder then return end
	local start = {}
	for _, name in Swings.joints(swing) do
		local motor = motors[name]
		if motor then start[name] = motor.Transform end -- blend from the current pose
	end
	local blade = character:FindFirstChild("Blade")
	local trail = blade and blade:FindFirstChild("SwingTrail") :: Trail?
	if previous and previous.trail and previous.trail ~= trail then previous.trail.Enabled = false end
	if trail then trail.Color = ColorSequence.new(TRAIL_COLORS[index] or TRAIL_COLORS[1]) end
	local now = os.clock()
	active[character] = { swing = swing, t0 = now, start = start, motors = motors, trail = trail }
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		task.delay(swing.whoosh, function()
			if root.Parent and active[character] and active[character].t0 == now then
				sound(root, WHOOSH, swing.pitch + 0.25, 0.6, 1.5)
			end
		end)
	end
end

-- PreSimulation, not PreRender: AnimationConstraint joints are solved in the physics step, after the
-- Animator has written its pose, so only a write here overrides idle/walk reliably (verified in Studio).
RunService.PreSimulation:Connect(function()
	local now = os.clock()
	for character, a in active do
		local t = now - a.t0
		if not character.Parent or t >= a.swing.duration then
			finish(character, a)
			continue
		end
		local pose = Swings.evaluate(a.swing, t, a.start)
		for name, cframe in pose do
			local motor = a.motors[name]
			if motor then motor.Transform = cframe end
		end
		if a.trail then a.trail.Enabled = t >= a.swing.trail[1] and t <= a.swing.trail[2] end
	end
end)

-- Local prediction: returns the swing index to play now, or nil while still on cooldown.
-- The server decides the real combo; sync() corrects this guess from its echo.
function SwingPlayer.predict(): number?
	local now = os.clock()
	if now < localCooldownUntil then return nil end
	localCooldownUntil = now + config.P0.Combo.CooldownSeconds
	localIndex = Swings.nextIndex(localIndex, localAt, now, config.P0.Combo.ResetSeconds)
	localAt = now
	return localIndex
end

function SwingPlayer.sync(index: number)
	localIndex, localAt = index, os.clock()
end

function SwingPlayer.impact(position: Vector3, index: number, killed: boolean)
	local anchor = Instance.new("Part")
	anchor.Anchored, anchor.CanCollide, anchor.CanQuery, anchor.CanTouch = true, false, false, false
	anchor.Transparency, anchor.Size, anchor.Position = 1, Vector3.one, position
	anchor.Parent = workspace
	local sparks = Instance.new("ParticleEmitter")
	sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparks.Color = ColorSequence.new(TRAIL_COLORS[index] or TRAIL_COLORS[1])
	sparks.LightEmission, sparks.Lifetime = 0.8, NumberRange.new(0.25, 0.45)
	sparks.Speed = NumberRange.new(14, if killed then 34 else 22)
	sparks.SpreadAngle = Vector2.new(180, 180)
	sparks.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.4), NumberSequenceKeypoint.new(1, 0) })
	sparks.Rate = 0
	sparks.Parent = anchor
	sparks:Emit(if killed then 26 else 14)
	sound(anchor, IMPACT, if killed then 1.25 else 1.6 + index * 0.05, if killed then 0.9 else 0.7, if killed then 0.9 else 0.5) -- stock sample is 2.6 s long: keep only the thump
	Debris:AddItem(anchor, 1.2)
	-- Tiny camera kick: heavier on the kill.
	local human = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
	if human then
		local strength = if killed then 0.5 else 0.28
		task.spawn(function()
			for i = 1, 6 do
				human.CameraOffset = Vector3.new((math.random() - 0.5) * strength, (math.random() - 0.5) * strength, 0) * (1 - i / 6)
				task.wait(0.02)
			end
			human.CameraOffset = Vector3.zero
		end)
	end
end

return SwingPlayer
