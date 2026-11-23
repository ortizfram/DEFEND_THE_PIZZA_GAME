local Shop = {}
local cheese = Color3.fromRGB(255, 192, 67)
local red = Color3.fromRGB(194, 63, 48)

local function part(parent, class, name, size, frame, color)
	local p = Instance.new(class)
	p.Name, p.Size, p.CFrame, p.Color = name, size, frame, color
	p.Anchored = true
	p.Parent = parent
	return p
end

-- scale: size multiplier of the central pizza (radius 4 studs at 1.0). Slice count stays 8.
function Shop.create(scale)
	scale = scale or 1
	local model = Instance.new("Model")
	model.Name = "DTP_PizzaShop"
	local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	local floor = spawn and spawn.Position + Vector3.yAxis * (spawn.Size.Y / 2) or Vector3.zero
	local center = floor + Vector3.new(0, 0, -18)
	local gray = Color3.fromRGB(108, 117, 124)
	part(model, "Part", "KitchenFloor", Vector3.new(60, 0.4, 60), CFrame.new(center), gray)
	local target = center + Vector3.yAxis * 0.22
	local slices = {}
	for i = 1, 8 do
		local frame = CFrame.new(target + Vector3.yAxis * 0.4 * scale) * CFrame.Angles(0, math.rad(i * 45), 0)
		local slice = Instance.new("Model")
		slice.Name = "Slice" .. i
		for _, sign in {-1, 1} do
			local radius = 4 * scale
			local width = radius * math.tan(math.pi / 8)
			local orientation = CFrame.fromMatrix(Vector3.new(sign * width/2, 0, radius / 2), -sign * Vector3.yAxis, sign * Vector3.xAxis)
			local wedge = part(slice, "WedgePart", "Cheese", Vector3.new(0.55 * scale, width, radius), frame * orientation, cheese)
			wedge.CanCollide = false
		end
		local topping = part(slice, "Part", "Pepperoni", Vector3.new(0.12 * scale, 0.8 * scale, 0.8 * scale), frame * CFrame.new(0, 0.32 * scale, 2.8 * scale) * CFrame.Angles(0, 0, math.pi/2), red)
		topping.Shape, topping.CanCollide = Enum.PartType.Cylinder, false
		-- Remember the intact geometry so the server can shrink the slice bite by bite (see showSlice in Bootstrap).
		slice:SetAttribute("Frame", frame)
		for _, p in slice:GetChildren() do
			p:SetAttribute("Rel", frame:ToObjectSpace(p.CFrame))
			p:SetAttribute("Base", p.Size)
		end
		slice.Parent = model
		slices[i] = slice
	end
	local entries = {}
	for i = 1, 3 do
		local frame = CFrame.new(center) * CFrame.Angles(0, math.rad((i-2)*90), 0) * CFrame.new(0, 0, -24)
		entries[i] = frame.Position + Vector3.yAxis * 0.2
		for _, sign in {-1, 1} do
			part(model, "Part", "Doorpost", Vector3.new(1, 7, 2), frame * CFrame.new(sign*4, 3.5, 0), red)
		end
		part(model, "Part", "Lintel", Vector3.new(9, 1, 2), frame * CFrame.new(0, 7, 0), red)
	end
	local door = part(model, "Part", "Shutter", Vector3.new(7, 6, 1), CFrame.new(entries[2] + Vector3.yAxis*3), gray)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText, prompt.ObjectText = "CLOSE", "Pizza Shop"
	prompt.RequiresLineOfSight = false
	prompt.Parent = door
	model.Parent = workspace
	return model, target, slices, entries, door, prompt
end

return Shop
