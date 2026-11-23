local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("DTP")
local round = shared:WaitForChild("Round")
local hit = round:WaitForChild("Hit")
local SwingPlayer = require(script.Parent.SwingPlayer)
round:WaitForChild("SwingFx").OnClientEvent:Connect(function(player, index)
	if player == Players.LocalPlayer then
		SwingPlayer.sync(index) -- server echo corrects the combo guess; visual already played
	elseif player.Character then
		SwingPlayer.play(player.Character, index)
	end
end)
round:WaitForChild("ImpactFx").OnClientEvent:Connect(SwingPlayer.impact)
task.spawn(function()
	local clips = shared:WaitForChild("MunchieClips",10)
	if clips then require(script.Parent.MunchiePlayback)(clips,workspace:WaitForChild("DTP_PizzaShop")) end
end)
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "PizzaShopHUD", false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local status = Instance.new("TextLabel")
status.AnchorPoint, status.Position = Vector2.new(0.5,0), UDim2.fromScale(0.5,0)
status.Size = UDim2.new(0.7,0,0,42)
status.Font, status.TextSize = Enum.Font.GothamBold, 19
status.TextColor3, status.BackgroundColor3 = Color3.new(1,1,1), Color3.fromRGB(51,40,42)
status.Parent = gui
Instance.new("UICorner",status)
-- Three hearts under the status bar (server-authoritative attribute on the character).
local heartIcons = {}
for i = 1, 3 do
	local heart = Instance.new("Frame")
	heart.AnchorPoint, heart.Position, heart.Size = Vector2.new(0.5,0), UDim2.new(0.5,(i-2)*34,0,50), UDim2.fromOffset(28,28)
	heart.BackgroundColor3 = Color3.fromRGB(239,90,76)
	heart.Parent = gui
	Instance.new("UICorner",heart).CornerRadius = UDim.new(1,0)
	local stroke = Instance.new("UIStroke",heart)
	stroke.Thickness, stroke.Color = 2, Color3.fromRGB(35,49,66)
	heartIcons[i] = heart
end
CAS:BindAction("PizzaHit", function(_, input)
	if input == Enum.UserInputState.Begin and round:GetAttribute("Phase") == "Defend" then
		local button = CAS:GetButton("PizzaHit")
		if button then
			button.ImageColor3 = Color3.fromRGB(255,192,67)
			task.delay(0.12,function() if button.Parent then button.ImageColor3 = Color3.new(1,1,1) end end)
		end
		-- Instant local swing (prediction); the server alone decides combo order, hit and damage.
		local index = SwingPlayer.predict()
		local character = Players.LocalPlayer.Character
		if index and character then
			SwingPlayer.play(character, index)
			hit:FireServer()
		end
	end
	return Enum.ContextActionResult.Pass
end,true,Enum.UserInputType.MouseButton1,Enum.KeyCode.F,Enum.KeyCode.ButtonR2)
CAS:SetTitle("PizzaHit","HIT")
CAS:SetPosition("PizzaHit",UDim2.new(1,-225,1,-165))
-- Touch layout: the stock jump button used to sit on top of HIT on phones (verified in the iPhone simulator).
-- Keep HIT immediately left of the jump button and at least 64 px (design token: 60 px touch targets).
local UIS = game:GetService("UserInputService")
local placed = ""
local function placeHit()
	local button = CAS:GetButton("PizzaHit")
	local jump = Players.LocalPlayer.PlayerGui:FindFirstChild("JumpButton", true)
	if not (button and button.Parent and jump) then return end
	local size = math.max(64, jump.AbsoluteSize.X)
	local frame = button.Parent
	local x = jump.AbsolutePosition.X - size - 14 - frame.AbsolutePosition.X
	local y = jump.AbsolutePosition.Y + (jump.AbsoluteSize.Y - size) / 2 - frame.AbsolutePosition.Y
	local key = string.format("%.0f,%.0f,%.0f", x, y, size)
	if key == placed then return end
	placed = key
	button.Size = UDim2.fromOffset(size, size)
	CAS:SetPosition("PizzaHit", UDim2.fromOffset(x, y))
end
while gui.Parent do
	local phase = round:GetAttribute("Phase")
	if phase == "Defend" then
		local seconds = math.max(0,math.ceil((round:GetAttribute("EndsAt") or 0)-workspace:GetServerTimeNow()))
		local bites = round:GetAttribute("SliceBites") or 0
		local biteText = bites > 0 and string.format("  ·  BITE %d/3", bites) or ""
		local stolenText = round:GetAttribute("Carried") == 1 and "  ·  THIEF HAS A SLICE - HIT HIM!" or ""
		-- PC players have no on-screen HIT button: a short hint in wave 1 only (touch shows the real button).
		local hint = (not UIS.TouchEnabled and (round:GetAttribute("Wave") or 1) == 1) and "  -  CLICK or F = HIT" or ""
		status.Text = string.format("WAVE %d/%d %s  -  PIZZA %d/8%s%s  -  %ds%s",round:GetAttribute("Wave") or 1,round:GetAttribute("WaveCount") or 3,
			round:GetAttribute("WaveName") or "",round:GetAttribute("Slices") or 8,biteText,stolenText,seconds,hint)
	elseif phase == "Transition" then
		status.Text = string.format("WAVE %d/%d - %s  -  GET READY",round:GetAttribute("Wave") or 2,round:GetAttribute("WaveCount") or 3,round:GetAttribute("WaveName") or "")
	else
		status.Text = string.upper(phase or "Waiting")
	end
	local me = Players.LocalPlayer.Character
	local hearts = me and me:GetAttribute("Hearts") or 3
	local downed = me ~= nil and me:GetAttribute("Downed") == true
	for i, heart in heartIcons do
		heart.BackgroundColor3 = if i <= hearts then Color3.fromRGB(239,90,76) else Color3.fromRGB(90,96,104)
	end
	game:GetService("ProximityPromptService").Enabled = not downed -- a downed chef cannot "revive" itself
	if downed and me then
		local left = math.max(0, math.ceil((me:GetAttribute("DownedUntil") or 0) - workspace:GetServerTimeNow()))
		status.Text = string.format("YOU ARE DOWN - a teammate can REVIVE you  ·  back up in %ds", left)
	end
	if UIS.TouchEnabled then placeHit() end
	task.wait(0.15)
end
