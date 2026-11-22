local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local shared = game:GetService("ReplicatedStorage"):WaitForChild("DTP")
local round = shared:WaitForChild("Round")
local hit = round:WaitForChild("Hit")
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
CAS:BindAction("PizzaHit", function(_, input)
	if input == Enum.UserInputState.Begin and round:GetAttribute("Phase") == "Defend" then
		local button = CAS:GetButton("PizzaHit")
		if button then
			button.ImageColor3 = Color3.fromRGB(255,192,67)
			task.delay(0.12,function() if button.Parent then button.ImageColor3 = Color3.new(1,1,1) end end)
		end
		hit:FireServer()
	end
	return Enum.ContextActionResult.Pass
end,true,Enum.UserInputType.MouseButton1,Enum.KeyCode.F,Enum.KeyCode.ButtonR2)
CAS:SetTitle("PizzaHit","HIT")
CAS:SetPosition("PizzaHit",UDim2.new(1,-145,1,-115))
while gui.Parent do
	local phase = round:GetAttribute("Phase")
	if phase == "Defend" then
		local seconds = math.max(0,math.ceil((round:GetAttribute("EndsAt") or 0)-workspace:GetServerTimeNow()))
		status.Text = string.format("SAVE THE PIZZA   %d/8   ·   %ds",round:GetAttribute("Slices") or 8,seconds)
	else
		status.Text = phase or "Waiting"
	end
	task.wait(0.15)
end
