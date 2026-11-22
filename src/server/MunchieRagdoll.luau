--!strict
-- One-shot, server-authoritative physics ragdoll for the rigid Munchie A rig.
-- No player characters, no Toolbox scripts, and no gameplay rewards here.
local Ragdoll = {}

function Ragdoll.launch(model: Model, direction: Vector3, horizontalSpeed: number, upSpeed: number, spin: Vector3?): boolean
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
            -- Only large shapes collide with the floor. Avoid self-collision
            -- on the 21-part mesh and keep physics inexpensive for mobile.
            item.CanCollide = item.Name == "Body" or item.Name == "Head"
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
    for _, item in model:GetDescendants() do
        if item:IsA("BasePart") then
            item.AssemblyLinearVelocity = velocity
        end
    end
    if spin then
        for _, item in model:GetDescendants() do
            if item:IsA("BasePart") then
                item.AssemblyAngularVelocity = spin -- swing-specific tumble (world axes, rad/s)
            end
        end
    else
        root:ApplyAngularImpulse(Vector3.new(0, 0.8, 0.4) * root.AssemblyMass)
    end
    return true
end

return Ragdoll
