--!strict
-- Bootstrap placeholder: no HUD, input, or gameplay is implemented yet.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("DTP"):WaitForChild("Config"))

print(('[Defend the Pizza] client scaffold loaded: %s'):format(Config.Version))
