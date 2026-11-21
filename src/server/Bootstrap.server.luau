--!strict
-- Bootstrap placeholder: no server gameplay is implemented yet.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("DTP"):WaitForChild("Config"))

print(('[Defend the Pizza] server scaffold loaded: %s'):format(Config.Version))
