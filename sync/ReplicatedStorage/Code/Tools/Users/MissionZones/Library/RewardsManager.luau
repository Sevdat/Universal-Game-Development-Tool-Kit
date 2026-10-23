local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local winReward = require(script.WinReward)
local allRewardGUID = workspace.AllRewards.GUID

local loopingMissionZones = require(script.Parent.LoopingMissionZones)

toolsModule.AddToPostInit(function()
	loopingMissionZones.Init()
end)

function module.RollWinReward()
	return winReward.RollWinReward()
end


return module
