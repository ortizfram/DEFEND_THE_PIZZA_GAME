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
local swingFx = Instance.new("RemoteEvent")
swingFx.Name = "SwingFx"
swingFx.Parent = state
local impactFx = Instance.new("RemoteEvent")
impactFx.Name = "ImpactFx"
impactFx.Parent = state
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
	clips:SetAttribute("WalkRate", config.P0.Walk.Rate)
	clips:SetAttribute("WalkStride", config.P0.Walk.Stride)
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
local Ragdoll = require(script.Parent.MunchieRagdoll)
local Swings = require(shared.SpatulaSwings)
local SpatulaHit = require(shared.SpatulaHit)
local active = {}
local cooldown = {}
local firstHit = {}
local combo = {}
local playing = false
local remaining, round, closedUntil, sliceBites = 0, 0, 0, 0

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
	grip.Name = "SpatulaGrip"
	grip.Part0, grip.Part1 = hand, handle
	grip.C0 = CFrame.new(0, -0.5, -0.3) * CFrame.Angles(-math.pi/2, 0, 0)
	grip.Parent = handle
	-- Blade trail: clients switch it on only during the fast part of each swing.
	local top = Instance.new("Attachment")
	top.Name, top.Position = "TrailTop", Vector3.new(0, 0.7, 0)
	top.Parent = blade
	local bottom = Instance.new("Attachment")
	bottom.Name, bottom.Position = "TrailBottom", Vector3.new(0, -0.7, 0)
	bottom.Parent = blade
	local trail = Instance.new("Trail")
	trail.Name, trail.Attachment0, trail.Attachment1 = "SwingTrail", top, bottom
	trail.Lifetime, trail.LightEmission, trail.FaceCamera, trail.Enabled = 0.16, 0.7, true, false
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
	trail.Parent = blade
end
local function joined(player)
	player.CharacterAdded:Connect(equip)
	if player.Character then task.spawn(equip, player.Character) end
end
Players.PlayerAdded:Connect(joined)
for _, player in Players:GetPlayers() do joined(player) end
Players.PlayerRemoving:Connect(function(p) cooldown[p], firstHit[p], combo[p] = nil, nil, nil end)

local function pose(enemy)
	local cf = CFrame.lookAt(enemy.pos, Vector3.new(target.X, enemy.pos.Y, target.Z))
	local hop = 0
	if enemy.hopUntil then
		local left = enemy.hopUntil - os.clock()
		if left > 0 then hop = enemy.hopHeight * math.sin(math.pi * (1 - left / 0.38)) else enemy.hopUntil = nil end
	end
	enemy.model:PivotTo(cf * CFrame.new(0, enemy.height + hop, 0) * enemy.offset)
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
	local enemy = {model=model, pos=entries[lane], hp=2, lane=lane, stun=0, bite=0, pendingBiteAt=nil, knockRemaining=0, knockDir=Vector3.zero, height=size.Y/2, offset=box:ToObjectSpace(model:GetPivot())}
	pose(enemy)
	model.Parent = arena
	active[enemy] = true
end
local function aliveRoot(p)
	local ch = p.Character
	local human = ch and ch:FindFirstChildOfClass("Humanoid")
	return human and human.Health > 0 and ch:FindFirstChild("HumanoidRootPart")
end
local function resolveImpact(player, index, thisRound, swingId)
	local root = aliveRoot(player)
	if not playing or thisRound ~= round or not root then return end
	local style = config.P0.Swing[index]
	-- Candidates: only zombies inside this swing's frontal arc and reach, with nothing solid in between.
	local ignore = {}
	for _, p in Players:GetPlayers() do if p.Character then table.insert(ignore, p.Character) end end
	local list = {}
	for enemy in active do
		table.insert(ignore, enemy.model)
		table.insert(list, {x = enemy.pos.X, z = enemy.pos.Z, enemy = enemy})
	end
	local params = RaycastParams.new()
	params.FilterType, params.RespectCanCollide, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, true, ignore
	local eye = root.Position
	local pick = SpatulaHit.select(eye.X, eye.Z, root.CFrame.LookVector.X, root.CFrame.LookVector.Z, list, style.Reach, style.ArcDeg,
		function(c)
			local to = Vector3.new(c.x, c.enemy.pos.Y + c.enemy.height, c.z)
			return workspace:Raycast(eye, to - eye, params) == nil -- walls, doorposts and the closed shutter block the blade
		end,
		function(c)
			-- Contact rule: any blade-tip point of this stroke close enough to the zombie's body counts as a hit.
			for _, tip in style.Tips do
				local w = root.CFrame:PointToWorldSpace(Vector3.new(tip[1], tip[2], tip[3]))
				if SpatulaHit.touches(w.X, w.Y, w.Z, c.x, c.z, c.enemy.pos.Y, c.enemy.pos.Y + 2 * c.enemy.height, config.P0.TouchRadius) then
					return true
				end
			end
			return false
		end)
	if not pick then return end
	local nearest = pick.enemy
	local key = player.UserId .. ":" .. swingId
	if nearest.lastSwing == key then return end -- one swing damages a zombie at most once
	nearest.lastSwing = key
	if not firstHit[player] then
		firstHit[player] = true
		print("DTP FirstAttackValidated", round)
	end
	local away = nearest.pos - Vector3.new(root.Position.X, nearest.pos.Y, root.Position.Z)
	if away.Magnitude < 0.01 then away = nearest.pos - target end
	if away.Magnitude < 0.01 then away = root.CFrame.LookVector end
	away = away.Unit
	-- Side swing travels right -> centre, so it shoves the zombie toward the chef's left.
	local push = if style.Lateral > 0 then (away * 0.45 - root.CFrame.RightVector * style.Lateral).Unit else away
	local hp, knockbackTarget = Munchie.hit(nearest.hp)
	nearest.hp = hp
	nearest.pendingBiteAt = nil -- A swing that connects before the bite impact cancels that bite.
	local model = nearest.model
	model:SetAttribute("HitKind", index)
	model:SetAttribute("Hp", hp)
	local contact = nearest.pos + Vector3.yAxis * nearest.height
	if hp > 0 then
		nearest.knockDir = push
		nearest.knockRemaining = knockbackTarget * style.Push
		nearest.stun = os.clock() + 0.42
		if style.Hop > 0 then nearest.hopUntil, nearest.hopHeight = os.clock() + 0.38, style.Hop end
		motion(model,"HitReaction",true)
	else
		active[nearest] = nil
		-- Final hit: always fly AWAY from the pizza (its rear), never into it.
		local toPizza = Vector3.new(target.X - nearest.pos.X, 0, target.Z - nearest.pos.Z)
		toPizza = if toPizza.Magnitude > 0.01 then toPizza.Unit else root.CFrame.LookVector
		local fly = -toPizza
		if style.Lateral > 0 then
			fly = fly * 0.45 - root.CFrame.RightVector * style.Lateral
			local into = fly:Dot(toPizza)
			if into > 0 then fly -= toPizza * into end -- strip any component that points at the pizza
			fly = if fly.Magnitude > 0.01 then fly.Unit else -toPizza
		end
		local spin
		if style.Spin == "Forward" then spin = Vector3.yAxis:Cross(fly) * style.SpinSpeed
		elseif style.Spin == "Back" then spin = fly:Cross(Vector3.yAxis) * style.SpinSpeed
		else spin = Vector3.yAxis * style.SpinSpeed + fly * 5 end
		local slam = if style.Slam then {Down = style.Slam, Delay = style.SlamDelay} else nil
		local launched = Ragdoll.launch(model, fly, style.KillSpeed, style.KillUp, spin, slam)
		if not launched then
			-- No rig (graybox block): visible flight rather than doing nothing.
			local block = model:FindFirstChildWhichIsA("BasePart")
			if block then
				TweenService:Create(block,TweenInfo.new(0.60,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
					{CFrame=block.CFrame + fly*knockbackTarget + Vector3.yAxis*6}):Play()
			end
			motion(model,"Knockback",true)
		end
		Debris:AddItem(model,config.P0.RagdollLifetimeSeconds)
	end
	impactFx:FireAllClients(contact, index, hp <= 0)
end
hit.OnServerEvent:Connect(function(player)
	local root = aliveRoot(player)
	local now = os.clock()
	if not playing or not root or now < (cooldown[player] or 0) then return end
	cooldown[player] = now + config.P0.Combo.ServerCooldownSeconds
	local chain = combo[player] or { index = 0, at = -math.huge }
	combo[player] = chain
	local index = Swings.nextIndex(chain.index, chain.at, now, config.P0.Combo.ResetSeconds)
	chain.index, chain.at = index, now
	chain.id = (chain.id or 0) + 1
	swingFx:FireAllClients(player, index) -- visuals only; damage waits for the visual contact below
	local thisRound = round
	task.delay(Swings.list[index].impact, resolveImpact, player, index, thisRound, chain.id)
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

local function showSlice(i, visible, biteCount)
	if not slices[i] then return end
	local bites = biteCount or 0
	for _, p in slices[i]:GetChildren() do
		if p:IsA("BasePart") then
			-- 0: fresh; 1: nibbled; 2: nearly eaten; 3: missing.
			if not visible then
				p.Transparency = 1
			elseif bites == 1 then
				p.Transparency = 0.12
			elseif bites == 2 then
				p.Transparency = 0.42
			else
				p.Transparency = 0
			end
			if p.Name == "Cheese" then
				p.Color = if bites == 0 then Color3.fromRGB(255,192,67)
					else if bites == 1 then Color3.fromRGB(235,158,54)
					else Color3.fromRGB(195,103,47)
			elseif p.Name == "Pepperoni" then
				p.Color = if bites == 0 then Color3.fromRGB(194,63,48)
					else Color3.fromRGB(128,48,42)
			end
		end
	end
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
	remaining, closedUntil, sliceBites, playing = #slices, 0, 0, true
	for i in slices do showSlice(i,true) end
	shutter(false)
	state:SetAttribute("Slices",remaining)
	state:SetAttribute("SliceBites",0)
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
			if enemy.knockRemaining > 0 then
				local distance = math.min(enemy.knockRemaining,config.P0.FirstHitPushSpeed*dt)
				enemy.pos += enemy.knockDir * distance
				enemy.knockRemaining -= distance
				pose(enemy)
			else
				local step, bite = Munchie.advance(toward.Magnitude, dt, now, enemy.stun, closedUntil > now and atDoor, enemy.bite, config.P0.MunchieSpeed)
				if closedUntil > now and atDoor and now >= enemy.stun then motion(enemy.model,"Idle") end
				if step > 0 then
					motion(enemy.model,"Walk")
					enemy.pos += toward.Unit * step
					pose(enemy)
				elseif bite and not enemy.pendingBiteAt then
					motion(enemy.model,"PizzaBite",true)
					enemy.bite = now + config.P0.BiteIntervalSeconds
					enemy.pendingBiteAt = now + config.P0.BiteHitDelaySeconds
				end
			end
			if enemy.hopUntil then pose(enemy) end
			if enemy.pendingBiteAt and now >= enemy.pendingBiteAt then
				enemy.pendingBiteAt = nil
				-- Damage follows the bite contact, and is canceled by stun/knockback.
				if now >= enemy.stun and enemy.knockRemaining <= 0
					and (target-enemy.pos).Magnitude <= 4.5 and remaining > 0 then
					local done
					sliceBites, done = Munchie.bite(sliceBites, config.P0.BitesPerSlice)
					showSlice(remaining,true,sliceBites)
					state:SetAttribute("SliceBites",sliceBites)
					if done then
						showSlice(remaining,false)
						remaining -= 1
						sliceBites = 0
						state:SetAttribute("Slices",remaining)
						state:SetAttribute("SliceBites",0)
						if remaining == 0 then finish("Pizza eaten!") break end
					end
				end
			end
		end
	end
	task.wait(4)
end
