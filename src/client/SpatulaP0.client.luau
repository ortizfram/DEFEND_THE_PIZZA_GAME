--!strict
-- P0 mobile / PC / controller slap input. Client sends intent only, never hits/damage.
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage:WaitForChild("DTP"):WaitForChild("Config"))
if not Config.P0.Enabled or game.PlaceId ~= Config.ApprovedPlaceId then
    return
end

local dtp = ReplicatedStorage:WaitForChild("DTP")
local request = dtp:WaitForChild("SpatulaSwingRequest") :: RemoteEvent
local feedback = dtp:WaitForChild("SpatulaHitFeedback") :: RemoteEvent
local lastLocalSwing = -math.huge

local gui = Instance.new("ScreenGui")
gui.Name = "DTP_P0_HitFeedback"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Name = "BonkFeedback"
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.fromScale(0.5, 0.69)
label.Size = UDim2.fromOffset(260, 75)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Font = Enum.Font.GothamBlack
label.TextStrokeTransparency = 0.35
label.TextColor3 = Color3.fromRGB(255, 226, 62)
label.TextTransparency = 1
label.Visible = false
label.Parent = gui

local activeTween: Tween? = nil
feedback.OnClientEvent:Connect(function(kind: string)
    if kind ~= "STAGGER" and kind ~= "LAUNCH" then
        return
    end
    if activeTween then
        activeTween:Cancel()
    end
    label.Text = kind == "LAUNCH" and "WHAM!" or "BONK!"
    label.Rotation = kind == "LAUNCH" and -12 or 9
    label.TextColor3 = kind == "LAUNCH"
        and Color3.fromRGB(255, 115, 46) or Color3.fromRGB(255, 226, 62)
    label.TextTransparency = 0
    label.Size = UDim2.fromOffset(260, 75)
    label.Visible = true
    local tween = TweenService:Create(
        label,
        TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {TextTransparency = 1, Size = UDim2.fromOffset(300, 95)}
    )
    activeTween = tween
    tween:Play()
    tween.Completed:Once(function()
        if activeTween == tween then
            label.Visible = false
            activeTween = nil
        end
    end)
end)

local function slap(_name: string, inputState: Enum.UserInputState, _input: InputObject): Enum.ContextActionResult
    if inputState ~= Enum.UserInputState.Begin then
        return Enum.ContextActionResult.Pass
    end
    local now = os.clock()
    if now - lastLocalSwing >= Config.P0.SwingCooldownSeconds then
        lastLocalSwing = now
        request:FireServer() -- server independently checks range, angle, cooldown, health
    end
    return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction(
    "DTP_P0_HIT",
    slap,
    true,
    Enum.UserInputType.MouseButton1,
    Enum.KeyCode.E,
    Enum.KeyCode.ButtonR2
)
ContextActionService:SetTitle("DTP_P0_HIT", "HIT")
ContextActionService:SetPosition("DTP_P0_HIT", UDim2.new(1, -118, 1, -160))
local touchButton = ContextActionService:GetButton("DTP_P0_HIT")
if touchButton then
    touchButton.Size = UDim2.fromOffset(86, 86)
end

print("[DTP P0] HIT controls bound for PC, controller and touch")
