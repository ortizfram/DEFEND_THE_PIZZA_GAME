--!strict
-- P0 server-authoritative two-hit Munchie and disposable pizza graybox.
-- Intentionally activates ONLY in the approved Defend The Pizza Place.
-- No purchases, data stores, publishing, or persistent Studio edits.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local AnalyticsService = game:GetService("AnalyticsService")
local RunService = game:GetService("RunService")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local Config = require(ReplicatedStorage:WaitForChild("DTP"):WaitForChild("Config"))
if not Config.P0.Enabled or game.PlaceId ~= Config.ApprovedPlaceId then
    warn("[DTP P0] DISABLED: Place ID mismatch or feature disabled; no world mutations.")
    return
end

local C = Config.P0
local dtp = ReplicatedStorage:WaitForChild("DTP")
local function remote(name: string): RemoteEvent
    local existing = dtp:FindFirstChild(name)
    if existing then
        assert(existing:IsA("RemoteEvent"), ("DTP/%s is not a RemoteEvent"):format(name))
        return existing
    end
    local new = Instance.new("RemoteEvent")
    new.Name = name
    new.Parent = dtp
    return new
end

local swingRequest = remote("SpatulaSwingRequest")
local hitFeedback = remote("SpatulaHitFeedback")
local lastSwing: {[Player]: number} = {}
local firstHit: {[Player]: boolean} = {}
local firstLaunch: {[Player]: boolean} = {}

local function analytics(player: Player, eventName: string)
    local ok, message = pcall(function()
        AnalyticsService:LogCustomEvent(player, eventName, 1, {
            version = Config.Version,
            enemy = "Munchie",
        })
    end)
    if not ok then
        warn(("[DTP analytics] %s: %s"):format(eventName, tostring(message)))
    end
end

local function onboarding(player: Player, step: number, stepName: string)
    local ok, message = pcall(function()
        AnalyticsService:LogOnboardingFunnelStepEvent(player, step, stepName, {
            version = Config.Version,
        })
    end)
    if not ok then
        warn(("[DTP onboarding] %s: %s"):format(stepName, tostring(message)))
    end
end

Players.PlayerAdded:Connect(function(player)
    onboarding(player, 1, "Joined")
end)
for _, player in Players:GetPlayers() do
    onboarding(player, 1, "Joined")
end
Players.PlayerRemoving:Connect(function(player)
    lastSwing[player] = nil
    firstHit[player] = nil
    firstLaunch[player] = nil
end)

-- Runtime-only pizza fallback. Does not replace or modify any authored pizza asset.
local runtime = Instance.new("Folder")
runtime.Name = "DTP_P0_Runtime"
runtime.Parent = Workspace
local pizzaCenter: BasePart
local slices: {BasePart} = {}

local authoredTarget = Workspace:FindFirstChild("DTP_PizzaTarget", true)
if authoredTarget and authoredTarget:IsA("BasePart") then
    pizzaCenter = authoredTarget
    local authoredSlices = Workspace:FindFirstChild("DTP_PizzaSlices", true)
    if authoredSlices then
        for _, part in authoredSlices:GetChildren() do
            if part:IsA("BasePart") then
                table.insert(slices, part)
            end
        end
    end
else
    local center = Instance.new("Part")
    center.Name = "DTP_PizzaTarget"
    center.Shape = Enum.PartType.Cylinder
    center.Size = Vector3.new(0.45, 8, 8)
    center.CFrame = CFrame.new(C.GreyboxPizzaPosition + Vector3.new(0, 0.4, 0))
        * CFrame.Angles(0, 0, math.rad(90))
    center.Anchored = true
    center.CanCollide = false
    center.CanQuery = false
    center.Color = Color3.fromRGB(198, 111, 51)
    center.Parent = runtime
    pizzaCenter = center

    local sliceFolder = Instance.new("Folder")
    sliceFolder.Name = "DTP_PizzaSlices"
    sliceFolder.Parent = runtime
    for i = 1, Config.PizzaSlices do
        local angle = (i - 1) * (math.pi * 2 / Config.PizzaSlices)
        local slice = Instance.new("Part")
        slice.Name = ("Slice_%02d"):format(i)
        slice.Size = Vector3.new(1.7, 0.13, 2.4)
        slice.CFrame = CFrame.new(C.GreyboxPizzaPosition + Vector3.new(
            math.sin(angle) * 2.0, 0.7, math.cos(angle) * 2.0
        )) * CFrame.Angles(0, angle, 0)
        slice.Anchored = true
        slice.CanCollide = false
        slice.Color = Color3.fromRGB(255, 190, 54)
        slice.Parent = sliceFolder
        table.insert(slices, slice)
    end
end

local remainingSlices = #slices
local function consumeSlice()
    for i = #slices, 1, -1 do
        local slice = slices[i]
        if slice.Parent then
            slice:Destroy()
            remainingSlices -= 1
            print(("[DTP P0] pizza bite; slices remaining = %d"):format(remainingSlices))
            return
        end
    end
end

type Munchie = {
    model: Model,
    root: BasePart,
    humanoid: Humanoid,
    health: number,
    state: string,
    tracks: {[string]: AnimationTrack},
}
local munchies: {[Model]: Munchie} = {}

local function resolveAnimationId(name: string): string?
    local published = Config.MunchieAnimationIds[name]
    if typeof(published) == "string" and published ~= "" then
        return published
    end
    if not RunService:IsStudio() then
        return nil
    end
    local saves = ServerStorage:FindFirstChild("RBX_ANIMSAVES")
    local folder = saves and saves:FindFirstChild(C.MunchieModelName)
    local sequence = folder and folder:FindFirstChild(name)
    if not sequence or not sequence:IsA("KeyframeSequence") then
        return nil
    end
    local ok, tempId = pcall(function()
        return KeyframeSequenceProvider:RegisterKeyframeSequence(sequence)
    end)
    if ok then
        return tempId :: string
    end
    warn("[DTP P0] Animation preview unavailable for " .. name)
    return nil
end

local function play(m: Munchie, name: string)
    local track = m.tracks[name]
    if not track then
        local id = resolveAnimationId(name)
        if not id then
            return
        end
        local animator = m.humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            return
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = id
        local ok, loaded = pcall(function()
            return animator:LoadAnimation(anim)
        end)
        anim:Destroy()
        if not ok then
            warn("[DTP P0] Unable to load " .. name .. ": " .. tostring(loaded))
            return
        end
        track = loaded :: AnimationTrack
        track.Looped = name == "Idle" or name == "Walk" or name == "Knockback"
        track.Priority = (name == "Idle" or name == "Walk")
            and Enum.AnimationPriority.Movement or Enum.AnimationPriority.Action
        m.tracks[name] = track
    end
    for key, other in m.tracks do
        if key ~= name and other.IsPlaying then
            other:Stop(0.08)
        end
    end
    if not track.IsPlaying then
        track:Play(0.08)
    end
end

local function register(model: Model)
    if munchies[model] or model.Name ~= C.MunchieModelName then
        return
    end
    local root = model:FindFirstChild("HumanoidRootPart")
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not root or not root:IsA("BasePart") or not humanoid then
        warn("[DTP P0] Model needs rig_munchie_a.luau first: " .. model:GetFullName())
        return
    end
    local m: Munchie = {
        model = model,
        root = root,
        humanoid = humanoid,
        health = C.MunchieHealth,
        state = "Approach",
        tracks = {},
    }
    munchies[model] = m
    model:SetAttribute("P0Health", m.health)
    model:SetAttribute("P0State", m.state)
    humanoid.WalkSpeed = C.MunchieWalkSpeed
    for _, obj in model:GetDescendants() do
        if obj:IsA("BasePart") then
            obj.Anchored = false
        end
    end
    local canSet = root:CanSetNetworkOwnership()
    if canSet then
        root:SetNetworkOwner(nil)
    end
    print("[DTP P0] server NPC registered: " .. model:GetFullName())

    task.spawn(function()
        while model.Parent and m.health > 0 do
            if m.state == "Approach" and remainingSlices > 0 then
                if (root.Position - pizzaCenter.Position).Magnitude <= C.PizzaBiteRangeStuds then
                    m.state = "Biting"
                    model:SetAttribute("P0State", m.state)
                    humanoid.WalkSpeed = 0
                    play(m, "PizzaBite")
                    task.delay(C.PizzaBiteSeconds, function()
                        if model.Parent and m.state == "Biting" and m.health > 0 then
                            consumeSlice()
                            m.state = "Approach"
                            model:SetAttribute("P0State", m.state)
                            humanoid.WalkSpeed = C.MunchieWalkSpeed
                        end
                    end)
                else
                    humanoid.WalkSpeed = C.MunchieWalkSpeed
                    humanoid:MoveTo(pizzaCenter.Position)
                    play(m, "Walk")
                end
            elseif m.state == "Approach" then
                play(m, "Idle")
            end
            task.wait(0.3)
        end
        munchies[model] = nil
    end)
end

for _, child in Workspace:GetChildren() do
    if child:IsA("Model") then
        register(child)
    end
end
Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == C.MunchieModelName then
        task.defer(function()
            if child.Parent then
                register(child)
            end
        end)
    end
end)

local function validTarget(player: Player, m: Munchie): (boolean, Vector3)
    local character = player.Character
    if not character or m.health <= 0 or m.state == "Launched" then
        return false, Vector3.zero
    end
    local human = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not human or human.Health <= 0 or not root or not root:IsA("BasePart") then
        return false, Vector3.zero
    end
    local delta = m.root.Position - root.Position
    local flat = Vector3.new(delta.X, 0, delta.Z)
    if flat.Magnitude < 0.01 or delta.Magnitude > C.SwingRangeStuds then
        return false, Vector3.zero
    end
    local forward = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
    if forward.Magnitude < 0.01 or forward.Unit:Dot(flat.Unit)
        < math.cos(math.rad(C.SwingHalfAngleDegrees)) then
        return false, Vector3.zero
    end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {character}
    rayParams.IgnoreWater = true
    local result = Workspace:Raycast(root.Position, delta, rayParams)
    if result and not result.Instance:IsDescendantOf(m.model) then
        return false, Vector3.zero
    end
    return true, flat.Unit
end

swingRequest.OnServerEvent:Connect(function(player: Player)
    -- No target, damage, power or timestamp is accepted from the client.
    local now = os.clock()
    if now - (lastSwing[player] or -math.huge) < C.SwingCooldownSeconds then
        return
    end
    lastSwing[player] = now
    for _, m in munchies do
        local valid, direction = validTarget(player, m)
        if valid then
            m.health -= 1
            m.model:SetAttribute("P0Health", m.health)
            m.humanoid.WalkSpeed = 0
            m.humanoid:MoveTo(m.root.Position)
            analytics(player, "DTP_SpatulaHitValidated")
            if not firstHit[player] then
                firstHit[player] = true
                onboarding(player, 2, "FirstAttackValidated")
            end

            if m.health > 0 then
                m.state = "Stunned"
                m.model:SetAttribute("P0State", m.state)
                play(m, "HitReaction")
                m.root:ApplyImpulse(direction * m.root.AssemblyMass * C.FirstHitImpulseSpeed)
                hitFeedback:FireClient(player, "STAGGER")
                task.delay(C.StaggerSeconds, function()
                    if m.model.Parent and m.state == "Stunned" and m.health > 0 then
                        m.state = "Approach"
                        m.model:SetAttribute("P0State", m.state)
                        m.humanoid.WalkSpeed = C.MunchieWalkSpeed
                    end
                end)
            else
                m.state = "Launched"
                m.model:SetAttribute("P0State", m.state)
                m.humanoid.AutoRotate = false
                m.humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                play(m, "Knockback")
                m.root:ApplyImpulse((
                    direction * C.LaunchHorizontalImpulseSpeed
                    + Vector3.new(0, C.LaunchVerticalImpulseSpeed, 0)
                ) * m.root.AssemblyMass)
                hitFeedback:FireClient(player, "LAUNCH")
                analytics(player, "DTP_MunchieLaunched")
                if not firstLaunch[player] then
                    firstLaunch[player] = true
                    if firstHit[player] then
                        onboarding(player, 3, "FirstKnockback")
                    end
                end
                task.delay(C.LaunchLifetimeSeconds * 0.55, function()
                    if m.model.Parent then
                        play(m, "Defeat")
                    end
                end)
                task.delay(C.LaunchLifetimeSeconds, function()
                    if m.model.Parent then
                        m.model:Destroy()
                    end
                end)
            end
            return -- P0 = one Munchie per valid tap; never multiply damage through overlap
        end
    end
end)

print("[DTP P0] combat active in authorized Place; Studio/playtest verification PENDING")
