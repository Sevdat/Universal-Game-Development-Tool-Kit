local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local isServer = game:GetService("RunService"):IsServer()

local allRewardGUID = workspace.AllRewards.GUID

function module.InitFolders()
	
	local allRewardPaths = toolsModule.GetAllToolPaths()
	
	for i,path in ipairs(allRewardPaths) do
		if not string.find(path,"Rewards_") then continue end
		if isServer then
			local toolTable = toolsModule.CreateTool(path,allRewardGUID)
		else
			local toolTable = toolsModule.CreateTool(allRewardGUID[path])
		end
	end
end

return module
