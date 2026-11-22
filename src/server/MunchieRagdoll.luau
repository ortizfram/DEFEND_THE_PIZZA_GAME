--!strict
-- One-shot, server-authoritative physics ragdoll for the rigid Munchie A rig.
-- No player characters, no Toolbox scripts, and no gameplay rewards here.
local Ragdoll = {}

-- Limbs must collide with the floor (otherwise they sink through it, measured 0.5 studs in Studio), but not
-- with each other: a collision group that ignores itself keeps the 21-part ragdoll stable and cheap.
local PhysicsService = game:GetService("PhysicsService")
local GROUP = "DTP_Ragdoll"
pcall(function() PhysicsService:RegisterCollisionGroup(GROUP) end)
pcall(function() PhysicsService:CollisionGroupSetCollidable(GROUP, GROUP, false) end)
local COLLIDES = {
    Body = true, Head = true,
    LeftUpperArm = true, LeftLowerArm = true, LeftHand = true, RightUpperArm = true, RightLowerArm = true, RightHand = true,
    LeftLeg = true, LeftFoot = true, RightLeg = true, RightFoot = true,
}

function Ragdoll.launch(model: Model, direction: Vector3, horizontalSpeed: number, upSpeed: number, spin: Vector3?, slam: {Down: number, Delay: number}?): boolean
    local root = model:FindFirstChild("HumanoidRootPart", true)
    local body = model:FindFirstChild("Body", true)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not (root and root:IsA("BasePart") and body and body:IsA("BasePart") and humanoid) then
        return false -- Placeholder models cannot physically ragdoll.
    end
    if model:GetAttribute("Ragdolled") then
        return false
    end

    local joints = {}
    for _, item in model:GetDescendants() do
        if item:IsA("Motor6D") and item.Part0 and item.Part1 and item.Name ~= "Root" then
            table.insert(joints, item)
        end
    end
    if #joints == 0 then return false end

    -- Tell the client animation player to stop overwriting Motor6D transforms.
    model:SetAttribute("Ragdolled", true)
    model:SetAttribute("Motion", "Ragdoll")

    -- Create the sockets before disabling motors, so no limb goes missing.
    for _, motor in joints do
        local a0 = Instance.new("Attachment")
        a0.Name = "RagdollA0"
        a0.CFrame = motor.C0
        a0.Parent = motor.Part0
        local a1 = Instance.new("Attachment")
        a1.Name = "RagdollA1"
        a1.CFrame = motor.C1
        a1.Parent = motor.Part1

        local socket = Instance.new("BallSocketConstraint")
        socket.Name = "DTP_RagdollJoint"
        socket.Attachment0, socket.Attachment1 = a0, a1
        socket.LimitsEnabled = true
        socket.UpperAngle = 60
        socket.TwistLimitsEnabled = true
        socket.TwistLowerAngle, socket.TwistUpperAngle = -35, 35
        socket.Parent = model

        local noCollision = Instance.new("NoCollisionConstraint")
        noCollision.Part0, noCollision.Part1 = motor.Part0, motor.Part1
        noCollision.Parent = model
    end

    humanoid.BreakJointsOnDeath = false
    humanoid.AutoRotate = false
    humanoid.PlatformStand = true

    for _, item in model:GetDescendants() do
        if item:IsA("BasePart") then
            item.Anchored = false
            item.CanTouch = false
            -- Body, head and limbs collide with the floor; face/belly details ride on their segment.
            item.CollisionGroup = GROUP
            item.CanCollide = COLLIDES[item.Name] == true
        end
    end
    root.CanCollide = false
    for _, motor in joints do
        motor.Enabled = false
    end

    pcall(function()
        root:SetNetworkOwner(nil) -- authoritative physics; never trust a client.
    end)
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    local flat = Vector3.new(direction.X, 0, direction.Z)
    if flat.Magnitude < 0.001 then flat = Vector3.new(0, 0, -1) end
    local velocity = flat.Unit * horizontalSpeed + Vector3.yAxis * upSpeed
    -- Every limb gets the launch velocity itself. An impulse on the torso alone left the limbs dragging
    -- it to ~half the commanded speed (measured in Studio), so jumps looked flat.
    local function setVelocities(linear: Vector3, angular: Vector3?)
        for _, item in model:GetDescendants() do
            if item:IsA("BasePart") then
                item.AssemblyLinearVelocity = linear
                if angular then
                    item.AssemblyAngularVelocity = angular -- swing-specific tumble (world axes, rad/s)
                end
            end
        end
    end
    if slam then
        -- Overhead: driven into the floor first, then it bounces away from the pizza.
        setVelocities(flat.Unit * horizontalSpeed * 0.2 - Vector3.yAxis * slam.Down, nil)
        task.delay(slam.Delay, function()
            if model.Parent and model:GetAttribute("Ragdolled") then
                setVelocities(velocity, spin)
            end
        end)
    else
        setVelocities(velocity, spin)
    end
    if not spin then
        root:ApplyAngularImpulse(Vector3.new(0, 0.8, 0.4) * root.AssemblyMass)
    end
    return true
end

return Ragdoll
