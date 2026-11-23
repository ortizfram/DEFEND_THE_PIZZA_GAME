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
	clips:SetAttribute("CarryPose", game:GetService("HttpService"):JSONEncode(config.P0.Thief.CarryPose))
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
local Ledger = require(script.Parent.SliceLedger)
local ChefRules = require(script.Parent.ChefRules)
local Swings = require(shared.SpatulaSwings)
local SpatulaHit = require(shared.SpatulaHit)
local active = {}
local cooldown = {}
local firstHit = {}
local combo = {}
local playing = false
local remaining, round, closedUntil, sliceBites = 0, 0, 0, 0
local onThiefHit -- assigned below (needs showSlice)
local registerChef -- assigned below (chef hearts)

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
	player.CharacterAdded:Connect(function(character)
		task.spawn(equip, character)
		task.defer(registerChef, character)
	end)
	if player.Character then
		task.spawn(equip, player.Character)
		task.defer(registerChef, player.Character)
	end
end
Players.PlayerAdded:Connect(joined)
for _, player in Players:GetPlayers() do joined(player) end
Players.PlayerRemoving:Connect(function(p) cooldown[p], firstHit[p], combo[p] = nil, nil, nil end)

local function pose(enemy)
	local aim = enemy.aim or target
	local look = Vector3.new(aim.X, enemy.pos.Y, aim.Z)
	if enemy.kind == "Thief" then
		-- Turn smoothly (540 deg/s) instead of snapping when it switches from the pizza to the exit.
		local desired = Vector3.new(aim.X - enemy.pos.X, 0, aim.Z - enemy.pos.Z)
		if desired.Magnitude > 0.01 then
			local clock = os.clock()
			local dtTurn = math.min(clock - (enemy.turnAt or clock), 0.1)
			enemy.turnAt = clock
			local current = enemy.heading or desired.Unit
			local want = desired.Unit
			local angle = math.atan2(current:Cross(want).Y, current:Dot(want))
			local step = math.clamp(angle, -math.rad(540) * dtTurn, math.rad(540) * dtTurn)
			current = CFrame.Angles(0, step, 0):VectorToWorldSpace(current)
			enemy.heading = current
			look = Vector3.new(enemy.pos.X + current.X, enemy.pos.Y, enemy.pos.Z + current.Z)
		end
	end
	local cf = CFrame.lookAt(enemy.pos, look)
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
-- ===== Chef hearts, DOWNED and free revive (server-authoritative; pure rules in ChefRules) =====
local chefs = {}
local function chefRoot(character) return character:FindFirstChild("HumanoidRootPart") end
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function setHearts(c) c.model:SetAttribute("Hearts", c.s.hearts) end
local function standUp(c, token)
	local cfg = config.P0.Chef
	if not ChefRules.standUp(c.s, os.clock(), cfg.Hearts, cfg.ReviveInvulnSeconds, token) then return false end
	local human = c.model:FindFirstChildOfClass("Humanoid")
	if human then
		human.PlatformStand = false
		human.WalkSpeed, human.JumpPower = c.walk or 16, c.jump or 50
	end
	if c.prompt then c.prompt:Destroy() c.prompt = nil end
	if c.help then c.help:Destroy() c.help = nil end
	c.model:SetAttribute("Downed", false)
	c.model:SetAttribute("DownedUntil", nil)
	setHearts(c)
	print("DTP_ChefUp", round, c.model.Name)
	return true
end
local function tryRevive(c, reviverCharacter)
	local r = reviverCharacter and chefs[reviverCharacter]
	local a, b = chefRoot(c.model), reviverCharacter and chefRoot(reviverCharacter)
	if not (r and a and b) then return false end
	local distance = (a.Position - b.Position).Magnitude
	if not ChefRules.canRevive(c.s, r.s, reviverCharacter ~= c.model, distance, config.P0.Chef.ReviveRange + 1) then return false end
	return standUp(c) -- a second trigger finds the chef already up and does nothing
end
local function setDowned(c)
	local cfg = config.P0.Chef
	local human = c.model:FindFirstChildOfClass("Humanoid")
	local root = chefRoot(c.model)
	if human then
		c.walk, c.jump = human.WalkSpeed, human.JumpPower
		human.PlatformStand, human.WalkSpeed, human.JumpPower = true, 0, 0
	end
	c.model:SetAttribute("Downed", true)
	c.model:SetAttribute("DownedUntil", workspace:GetServerTimeNow() + cfg.DownedMaxSeconds)
	local head = c.model:FindFirstChild("Head")
	if head then
		local gui = Instance.new("BillboardGui")
		gui.Name, gui.Size, gui.StudsOffset, gui.AlwaysOnTop = "HelpSign", UDim2.fromOffset(120, 44), Vector3.new(0, 3.2, 0), true
		local label = Instance.new("TextLabel")
		label.Size, label.BackgroundTransparency, label.Text = UDim2.fromScale(1, 1), 1, "HELP!"
		label.Font, label.TextScaled, label.TextColor3 = Enum.Font.GothamBold, true, Color3.fromRGB(239, 90, 76)
		label.TextStrokeTransparency = 0
		label.Parent = gui
		gui.Parent = head
		c.help = gui
	end
	if root then
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name, prompt.ActionText, prompt.ObjectText = "RevivePrompt", "REVIVE", "Chef down"
		prompt.HoldDuration, prompt.MaxActivationDistance, prompt.RequiresLineOfSight = cfg.ReviveSeconds, cfg.ReviveRange, false
		prompt.Parent = root
		c.prompt = prompt
		prompt.Triggered:Connect(function(player) tryRevive(c, player.Character) end)
	end
	local token = c.s.token
	-- Free self-recovery: alone or unhelped, the chef is back up within DownedMaxSeconds.
	task.delay(cfg.DownedMaxSeconds, function()
		if chefs[c.model] == c and c.s.token == token then standUp(c, token) end
	end)
end
local function damageChef(character, now)
	local c = chefs[character]
	if not c then return end
	local ok, what = ChefRules.damage(c.s, now, config.P0.Chef.InvulnSeconds)
	if not ok then return end
	setHearts(c)
	local root = chefRoot(character)
	if root then impactFx:FireAllClients(root.Position + Vector3.yAxis, 1, false) end
	if what == "downed" then setDowned(c) end
	print("DTP_ChefBitten", round, c.s.hearts, what)
end
registerChef = function(character)
	if chefs[character] or not character.Parent then return end
	local c = {model = character, s = ChefRules.new(config.P0.Chef.Hearts)}
	chefs[character] = c
	setHearts(c)
	character:SetAttribute("Downed", false)
	character.Destroying:Once(function() chefs[character] = nil end)
end
local function resetChefs()
	for _, c in chefs do
		if c.s.downed then standUp(c) end
		ChefRules.reset(c.s, config.P0.Chef.Hearts)
		setHearts(c)
	end
end
if RunService:IsStudio() then
	-- Studio-only test hook (does not exist on live servers): playtests register NPC chefs and drive bites/revives.
	local bridge = Instance.new("BindableFunction")
	bridge.Name = "DTP_ChefTest"
	bridge.OnInvoke = function(action, a, b)
		if action == "register" then registerChef(a) return true
		elseif action == "damage" then damageChef(a, os.clock()) return true
		elseif action == "revive" then return tryRevive(chefs[a], b)
		end
		return false
	end
	bridge.Parent = script
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
	nearest.chefBiteAt = nil
	local model = nearest.model
	model:SetAttribute("HitKind", index)
	model:SetAttribute("Hp", hp)
	local contact = nearest.pos + Vector3.yAxis * nearest.height
	if nearest.kind == "Thief" then onThiefHit(nearest) end -- a valid hit makes it drop the slice it carries
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
	local own = chefs[player.Character]
	if own and own.s.downed then return end -- a downed chef cannot attack
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
-- ===== Slice Thief (provisional model = recoloured, smaller Munchie rig carrying a big slice) =====
local thiefLedger = Ledger.new()
local finish -- assigned below
local function renderSlices(skip)
	for i = 1, #slices do
		if i == skip or i > remaining then
			showSlice(i, false)
		else
			showSlice(i, true, if i == remaining then sliceBites else 0)
		end
	end
end
local function makeCarried(idx)
	local clone = slices[idx]:Clone()
	clone.Name = "StolenSlice"
	for _, p in clone:GetDescendants() do
		if p:IsA("BasePart") then p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery, p.Transparency = true, false, false, false, 0 end
	end
	clone.WorldPivot = CFrame.new(clone:GetBoundingBox().Position) * CFrame.Angles(0, math.rad(idx * 45), 0)
	clone:ScaleTo(config.P0.Thief.CarryScale)
	clone.Parent = arena
	return clone
end
-- The carried slice is WELDED to the hat: clients play the Munchie pose locally, and welded parts follow it,
-- so the slice never floats away from the head while the thief runs or turns.
local function attachSlice(enemy, clone)
	for _, p in clone:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored, p.Massless = false, true
			local weld = Instance.new("WeldConstraint")
			weld.Name, weld.Part0, weld.Part1 = "SliceWeld", enemy.cap, p
			weld.Parent = p
		end
	end
	clone.Parent = enemy.model
	enemy.sliceWelded = true
end
local function detachSlice(enemy)
	local clone = enemy.slice
	for _, p in clone:GetDescendants() do
		if p:IsA("WeldConstraint") then p:Destroy() end
		if p:IsA("BasePart") then p.Anchored = true end
	end
	clone.Parent = arena
	enemy.sliceWelded = false
	return clone
end
local function flySlice(clone, slot, thisRound)
	task.spawn(function()
		local from = clone:GetPivot()
		local to = CFrame.new(slices[slot]:GetBoundingBox().Position)
		for k = 1, 10 do
			task.wait(0.035)
			if not clone.Parent then return end
			clone:PivotTo(from:Lerp(to, k / 10) + Vector3.new(0, math.sin(math.pi * k / 10) * 2.5, 0))
		end
		clone:Destroy()
		if thisRound == round and playing then renderSlices() end
	end)
end
local function spawnThief()
	local cfg = config.P0.Thief
	if not template then return end
	local lane = ({1, 3})[math.random(1, 2)]
	local model = template:Clone()
	model:ScaleTo(cfg.Scale)
	local purple, dark, gold = Color3.fromRGB(122, 84, 176), Color3.fromRGB(38, 36, 52), Color3.fromRGB(255, 209, 102)
	local head, capPart
	for _, p in model:GetDescendants() do
		if p:IsA("MeshPart") then
			local n = p.Name
			if n == "Head" then head = p end
			if n == "Body" or n == "Head" or n:find("Arm") or n:find("Leg") or n:find("Hand") then p.Color = purple
			elseif n == "Belly" then p.Color = dark
			elseif n == "Bib" then p.Color = gold end
		end
	end
	if head then
		local cap = Instance.new("Part")
		cap.Name, cap.Color, cap.Material = "ThiefCap", dark, Enum.Material.SmoothPlastic
		cap.Size = Vector3.new(head.Size.X * 1.06, head.Size.Y * 0.05, head.Size.Z * 1.06)
		cap.CanCollide, cap.CanTouch, cap.CanQuery, cap.Massless = false, false, false, true
		cap.CFrame = head.CFrame * CFrame.new(0, head.Size.Y * 0.475, 0)
		cap.Parent = model
		capPart = cap
		local weld = Instance.new("WeldConstraint")
		weld.Part0, weld.Part1, weld.Parent = head, cap, cap
	end
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored, p.CanCollide, p.CanTouch = (not model.PrimaryPart or p == model.PrimaryPart), false, false
		end
	end
	motion(model, "Walk")
	model.Name = "Munchie" -- same rig and clips as the common zombie
	model:SetAttribute("Thief", true)
	model:SetAttribute("GaitMul", cfg.GaitMul)
	local box, size = model:GetBoundingBox()
	local enemy = {model=model, kind="Thief", state="Approach", pos=entries[lane], hp=cfg.Hp, lane=lane, exit=entries[lane], cap=capPart, carryId=0,
		stun=0, bite=0, knockRemaining=0, knockDir=Vector3.zero, height=size.Y/2, offset=box:ToObjectSpace(model:GetPivot())}
	pose(enemy)
	model.Parent = arena
	active[enemy] = true
	print("DTP_ThiefSpawned", round, lane)
end
local function stealSlice(enemy)
	local idx = remaining
	local left, ok = Ledger.steal(thiefLedger, remaining)
	enemy.aim = enemy.exit -- runs for the exit either way
	if not ok then enemy.state = "Flee" return end
	local clone = makeCarried(idx)
	enemy.slice = clone
	enemy.carryId += 1
	local id = enemy.carryId
	remaining, sliceBites, enemy.state = left, 0, "Escape"
	enemy.model:SetAttribute("CarryAt", workspace:GetServerTimeNow()) -- clients raise both arms
	-- Visibility aid: a white outline (visible through obstacles) while it carries the slice, so players spot it.
	local glow = Instance.new("Highlight")
	glow.Name, glow.Adornee, glow.FillTransparency, glow.OutlineTransparency = "CarryGlow", enemy.model, 1, 0
	glow.OutlineColor, glow.DepthMode = Color3.fromRGB(255, 255, 255), Enum.HighlightDepthMode.AlwaysOnTop
	glow.Parent = enemy.model
	enemy.glow = glow
	-- The slice rises from the pizza onto the hat (0.3 s), then gets welded there.
	local _, bounds = clone:GetBoundingBox()
	local onHat = CFrame.new(0, enemy.cap.Size.Y / 2 + bounds.Y / 2 + 0.005, 0) * CFrame.Angles(0, math.pi, 0)
	task.spawn(function()
		local from = clone:GetPivot()
		for k = 1, 8 do
			task.wait(0.035)
			if enemy.carryId ~= id or not clone.Parent or not enemy.model.Parent then return end
			clone:PivotTo(from:Lerp(enemy.cap.CFrame * onHat, k / 8) + Vector3.new(0, math.sin(math.pi * k / 8) * 1.0, 0))
		end
		if enemy.carryId == id and enemy.model.Parent then
			clone:PivotTo(enemy.cap.CFrame * onHat)
			attachSlice(enemy, clone)
		end
	end)
	state:SetAttribute("Slices", remaining)
	state:SetAttribute("SliceBites", 0)
	state:SetAttribute("Carried", 1)
	renderSlices()
	print("DTP_SliceStolen", round, remaining)
end
local function escapeThief(enemy)
	if Ledger.escape(thiefLedger) then
		state:SetAttribute("StolenLost", thiefLedger.lost)
		state:SetAttribute("Carried", 0)
		print("DTP_SliceLost", round, remaining)
	end
	if enemy.slice then enemy.slice:Destroy() enemy.slice = nil end
	active[enemy] = nil
	enemy.model:Destroy()
	if remaining == 0 and playing then finish("Pizza eaten!") end -- the last slice is gone for good
end
onThiefHit = function(enemy)
	local left, ok = Ledger.recover(thiefLedger, remaining, #slices)
	if not ok then return end -- not carrying (or already recovered): nothing to give back
	remaining = left
	state:SetAttribute("Slices", remaining)
	state:SetAttribute("Carried", 0)
	enemy.carryId += 1 -- cancels a slice still rising onto the hat
	local clone = enemy.slice
	if enemy.sliceWelded then clone = detachSlice(enemy) end
	enemy.slice, enemy.state, enemy.aim = nil, "Flee", enemy.exit
	enemy.model:SetAttribute("CarryAt", nil) -- clients lower the arms
	if enemy.glow then enemy.glow:Destroy() enemy.glow = nil end
	renderSlices(remaining) -- the landing slot stays empty until the slice flies back
	flySlice(clone, remaining, round)
	print("DTP_SliceRecovered", round, remaining)
end
local function stepThief(enemy, dt, now)
	local cfg = config.P0.Thief
	if enemy.knockRemaining > 0 then
		local d = math.min(enemy.knockRemaining, config.P0.FirstHitPushSpeed * dt)
		enemy.pos += enemy.knockDir * d
		enemy.knockRemaining -= d
		pose(enemy)
		return
	end
	if now < enemy.stun then return end
	local dest = if enemy.state == "Approach" then target else enemy.exit
	local to = Vector3.new(dest.X - enemy.pos.X, 0, dest.Z - enemy.pos.Z)
	local dist = to.Magnitude
	if enemy.state == "Approach" then
		if dist <= cfg.StealDistance then stealSlice(enemy) return end
	elseif dist <= cfg.ExitRadius then
		escapeThief(enemy)
		return
	end
	motion(enemy.model, "Walk")
	enemy.pos += to.Unit * math.min(cfg.Speed * dt, dist)
	pose(enemy)
end

function finish(result)
	playing = false
	for enemy in active do
		if enemy.slice then enemy.slice:Destroy() end
		enemy.model:Destroy()
	end
	state:SetAttribute("Carried", 0)
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
	Ledger.reset(thiefLedger)
	resetChefs()
	state:SetAttribute("Carried", 0)
	state:SetAttribute("StolenLost", 0)
	shutter(false)
	state:SetAttribute("Slices",remaining)
	state:SetAttribute("SliceBites",0)
	state:SetAttribute("EndsAt",workspace:GetServerTimeNow()+config.P0.WaveDurationSeconds)
	state:SetAttribute("Phase","Defend")
	print("DTP_MapStarted",round,#Players:GetPlayers())
	local started, nextSpawn, index = os.clock(), 0, 0
	local thiefSpawned = false
	local thiefAt = config.P0.Thief.SpawnMin + math.random() * (config.P0.Thief.SpawnMax - config.P0.Thief.SpawnMin)
	while playing do
		local dt = math.min(RunService.Heartbeat:Wait(),0.2)
		local now = os.clock()
		if #Players:GetPlayers() == 0 then finish("Waiting") break end
		if now-started >= config.P0.WaveDurationSeconds then finish(if remaining > 0 then "Pizza saved!" else "Pizza eaten!") break end
		if not thiefSpawned and now - started >= thiefAt then thiefSpawned = true spawnThief() end
		if now >= nextSpawn then
			index += 1
			spawnEnemy((index-1)%#entries+1)
			nextSpawn = now+3
		end
		if closedUntil > 0 and now >= closedUntil then closedUntil=0 shutter(false) end
		for enemy in active do
			if enemy.kind == "Thief" then
				stepThief(enemy, dt, now)
				if not playing then break end
				continue
			end
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
			-- Counterattack: a common Munchie bites a chef standing in its way, then keeps going for the pizza.
			if enemy.chefBiteAt then
				if now >= enemy.chefBiteAt then
					local victim = enemy.chefVictim
					enemy.chefBiteAt, enemy.chefVictim = nil, nil
					local vr = victim and chefs[victim] and chefRoot(victim)
					if vr and (flat(vr.Position) - flat(enemy.pos)).Magnitude <= config.P0.Chef.BiteRange + 0.8 then
						damageChef(victim, now)
					end
				end
			elseif now >= enemy.stun and enemy.knockRemaining <= 0 and now >= (enemy.chefCooldown or 0) then
				local forward = flat(target - enemy.pos)
				for character, c in chefs do
					local vr = chefRoot(character)
					if vr and not c.s.downed then
						local to = flat(vr.Position) - flat(enemy.pos)
						local ahead = to.Magnitude < 0.05 or (forward.Magnitude > 0.01 and forward.Unit:Dot(to.Unit) > 0.2)
						if to.Magnitude <= config.P0.Chef.BiteRange and ahead then
							motion(enemy.model, "AttackChef", true)
							enemy.stun = now + config.P0.Chef.BiteWindup + 0.15 -- holds still while it winds up
							enemy.chefBiteAt = now + config.P0.Chef.BiteWindup
							enemy.chefVictim = character
							enemy.chefCooldown = now + config.P0.Chef.BiteCooldown
							break
						end
					end
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
