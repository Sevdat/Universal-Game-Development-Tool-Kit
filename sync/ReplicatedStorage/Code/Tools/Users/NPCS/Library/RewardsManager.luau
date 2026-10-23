local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local allRewardGUID = workspace.AllRewards.GUID

function module.DropReward(position)
	local toolTable = toolsModule.CreateTool(workspace.AllRewards.GUID:FindFirstChild("Rewards_Cash_Default"))
	if toolTable then
		toolTable:Interface("DropReward",position)
	end
end



return module
