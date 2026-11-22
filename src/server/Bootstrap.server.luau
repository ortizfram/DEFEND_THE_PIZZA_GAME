local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local shared = ReplicatedStorage:WaitForChild("DTP")
local config = require(shared.Config)
local arena, target, slices, entries, door, prompt = require(script.Parent.PizzaShop).create()
local hit = Instance.new("RemoteEvent")
hit.Name = "Hit"
local state = Instance.new("Folder")
state.Name = "Round"
hit.Parent = state
state.Parent = shared

local template
for _, candidate in workspace:GetChildren() do
	if candidate.Name == "Zombie_Munchie_A" and candidate:IsA("Model") and candidate:FindFirstChild("HumanoidRootPart", true) then
		template = candidate
		break
	end
end
local storage = game:GetService("ServerStorage")
local saves = storage:FindFirstChild("RBX_ANIMSAVES")
local saved = saves and saves:FindFirstChild("Zombie_Munchie_A")
if saved then
	local clips = Instance.new("Folder")
	clips.Name = "MunchieClips"
	for _, sequence in saved:GetChildren() do
		if sequence:IsA("KeyframeSequence") then sequence:Clone().Parent = clips end
	end
	clips.Parent = shared
end
for _, candidate in workspace:GetChildren() do
	if candidate:IsA("Model") and candidate.Name == "Zombie_Munchie_A" then candidate.Parent = storage end
end
local function motion(model,name,restart)
	if restart or model:GetAttribute("Motion") ~= name then
		model:SetAttribute("MotionAt",workspace:GetServerTimeNow())
		model:SetAttribute("Motion",name)
	end
end
local Munchie = require(script.Parent.Munchie)
local active = {}
local cooldown = {}
local firstHit = {}
local grips = {}
local playing = false
local remaining, round, closedUntil = 0, 0, 0

local function equip(character)
	local hand = character:WaitForChild("RightHand", 3) or character:FindFirstChild("Right Arm")
	if not hand or not character.Parent then return end
	local handle = Instance.new("Part")
	handle.Name, handle.Size = "Spatula", Vector3.new(0.22, 2.4, 0.22)
	handle.Color = Color3.fromRGB(120, 68, 36)
	local blade = Instance.new("Part")
	blade.Name, blade.Size = "Blade", Vector3.new(1.35, 1.4, 0.18)
	blade.Color = Color3.fromRGB(209, 220, 225)
	for _, p in {handle, blade} do
		p.CanCollide, p.CanTouch, p.CanQuery, p.Massless = false, false, false, true
		p.Parent = character
	end
	local weld = Instance.new("Weld")
	weld.Part0, weld.Part1, weld.C0 = handle, blade, CFrame.new(0, 1.7, 0)
	weld.Parent = handle
	local grip = Instance.new("Motor6D")
	grip.Part0, grip.Part1 = hand, handle
	grip.C0 = CFrame.new(0, -0.5, -0.3) * CFrame.Angles(-math.pi/2, 0, 0)
	grip.Parent = handle
	grips[character] = grip
	character.Destroying:Once(function() grips[character] = nil end)
end
local function joined(player)
	player.CharacterAdded:Connect(equip)
	if player.Character then task.spawn(equip, player.Character) end
end
Players.PlayerAdded:Connect(joined)
for _, player in Players:GetPlayers() do joined(player) end
Players.PlayerRemoving:Connect(function(p) cooldown[p], firstHit[p] = nil, nil end)

local function pose(enemy)
	local cf = CFrame.lookAt(enemy.pos, Vector3.new(target.X, enemy.pos.Y, target.Z))
	enemy.model:PivotTo(cf * CFrame.new(0, enemy.height, 0) * enemy.offset)
end
local function spawnEnemy(lane)
	local model = template and template:Clone() or Instance.new("Model")
	if not template then
		local body = Instance.new("Part")
		body.Name, body.Size, body.Color = "Munchie", Vector3.new(3, 4, 2), Color3.fromRGB(130, 203, 124)
		body.Parent = model
	end
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored, p.CanCollide, p.CanTouch = (not model.PrimaryPart or p == model.PrimaryPart), false, false
		end
	end
	motion(model,"Walk")
	model.Name = "Munchie"
	local box, size = model:GetBoundingBox()
	local enemy = {model=model, pos=entries[lane], hp=2, lane=lane, stun=0, bite=0, height=size.Y/2, offset=box:ToObjectSpace(model:GetPivot())}
	pose(enemy)
	model.Parent = arena
	active[enemy] = true
end
local function aliveRoot(p)
	local ch = p.Character
	local human = ch and ch:FindFirstChildOfClass("Humanoid")
	return human and human.Health > 0 and ch:FindFirstChild("HumanoidRootPart")
end
hit.OnServerEvent:Connect(function(player)
	local root = aliveRoot(player)
	local now = os.clock()
	if not playing or not root or now < (cooldown[player] or 0) then return end
	cooldown[player] = now + 0.4
	local grip = grips[player.Character]
	if grip then
		local rest = CFrame.new(0,-0.5,-0.3) * CFrame.Angles(-math.pi/2,0,0)
		grip.C0 = rest * CFrame.Angles(0,0,-1.3)
		TweenService:Create(grip, TweenInfo.new(0.22), {C0=rest}):Play()
	end
	local nearest, distance = nil, 9
	for enemy in active do
		local delta = enemy.pos + Vector3.yAxis * enemy.height - root.Position
		if delta.Magnitude <= distance and (delta.Magnitude < 2 or root.CFrame.LookVector:Dot(delta.Unit) >= 0.1) then
			nearest, distance = enemy, delta.Magnitude
		end
	end
	if not nearest then return end
	if not firstHit[player] then
		firstHit[player] = true
		print("DTP FirstAttackValidated", round)
	end
	local away = nearest.pos - target
	local hp, knockback = Munchie.hit(nearest.hp)
	nearest.hp = hp
	nearest.pos += away.Unit * knockback
	nearest.stun = now + 0.35
	pose(nearest)
	motion(nearest.model,if hp == 0 then "Knockback" else "HitReaction",true)
	if nearest.hp == 0 then
		active[nearest] = nil
		Debris:AddItem(nearest.model, 1.32)
	end
end)

local function shutter(closed)
	door.Transparency = closed and 0 or 0.9
	door.CanCollide = closed
	prompt.Enabled = playing and not closed
end
prompt.Triggered:Connect(function(player)
	local root = aliveRoot(player)
	if playing and root and os.clock() >= closedUntil and (root.Position-door.Position).Magnitude <= prompt.MaxActivationDistance+1 then
		closedUntil = os.clock()+4
		shutter(true)
		print("DTP_MapObjectiveUsed", round, "CLOSE")
	end
end)

local function showSlice(i, visible)
	for _, p in slices[i]:GetChildren() do p.Transparency = visible and 0 or 1 end
end
local function finish(result)
	playing = false
	for enemy in active do enemy.model:Destroy() end
	table.clear(active)
	shutter(false)
	state:SetAttribute("Phase", result)
	print("DTP RoundFinished", round, result, remaining)
end
state:SetAttribute("Phase","Waiting")
shutter(false)
while true do
	while #Players:GetPlayers() == 0 do task.wait(0.25) end
	round += 1
	remaining, closedUntil, playing = #slices, 0, true
	for i in slices do showSlice(i,true) end
	shutter(false)
	state:SetAttribute("Slices",remaining)
	state:SetAttribute("EndsAt",workspace:GetServerTimeNow()+config.P0.WaveDurationSeconds)
	state:SetAttribute("Phase","Defend")
	print("DTP_MapStarted",round,#Players:GetPlayers())
	local started, nextSpawn, index = os.clock(), 0, 0
	while playing do
		local dt = math.min(RunService.Heartbeat:Wait(),0.2)
		local now = os.clock()
		if #Players:GetPlayers() == 0 then finish("Waiting") break end
		if now-started >= config.P0.WaveDurationSeconds then finish("Pizza saved!") break end
		if now >= nextSpawn then
			index += 1
			spawnEnemy((index-1)%#entries+1)
			nextSpawn = now+3
		end
		if closedUntil > 0 and now >= closedUntil then closedUntil=0 shutter(false) end
		for enemy in active do
			local toward = target-enemy.pos
			local atDoor = enemy.lane == 2 and (enemy.pos-entries[2]).Magnitude < 2
			local step, bite = Munchie.advance(toward.Magnitude, dt, now, enemy.stun, closedUntil > now and atDoor, enemy.bite)
			if closedUntil > now and atDoor and now >= enemy.stun then motion(enemy.model,"Idle") end
			if step > 0 then
				motion(enemy.model,"Walk")
				enemy.pos += toward.Unit * step
				pose(enemy)
			elseif bite then
				motion(enemy.model,"PizzaBite",true)
				enemy.bite = now+2
				showSlice(remaining,false)
				remaining -= 1
				state:SetAttribute("Slices",remaining)
				if remaining == 0 then finish("Pizza eaten!") break end
			end
		end
	end
	task.wait(4)
end
