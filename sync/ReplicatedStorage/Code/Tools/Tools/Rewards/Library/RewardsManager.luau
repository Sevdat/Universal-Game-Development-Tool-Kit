local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local runService = game:GetService("RunService")
local isServer = runService:IsServer()
local isStudio = runService:IsStudio()

local allRewards = workspace.AllRewards
module.Vacuum = allRewards.Vacuum

local spawnableRewards = workspace.SpawnableRewards
local pool = spawnableRewards.Pool

module.SpawnRewards = require(script.SpawnableRewards).new()

toolsModule.AddToPostInit(function()
	module.SpawnRewards:Init()
end)

function module.DropReward(position)
	if isServer then
		local part = Instance.new("Part")
		part.Position = position
		part.Size = Vector3.new(7,7,7)
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = isStudio and 0.7 or 1
		part.Parent = pool
	end
end

return module
