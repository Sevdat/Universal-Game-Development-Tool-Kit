local module = {}

local isclient = game:GetService("RunService"):IsClient()

module.DropRewardRemote = script.DropRewardRemote

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

if isclient then
	module.DropRewardRemote.OnClientEvent:Connect(function(GUIDObject)
		if GUIDObject ~= nil then
			local missionZone = toolsModule.GetTool(GUIDObject.Value)
			if missionZone then
				missionZone:Interface("DropReward")
			end
		end
	end)
end

return module
