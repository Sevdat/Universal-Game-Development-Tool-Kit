local module = {}

local isclient = game:GetService("RunService"):IsClient()

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

module.UpgradeRemote = script.UpgradeRemote

if isclient then
	module.UpgradeRemote.OnClientEvent:Connect(function(GUIDObject,armourStandName)
		if GUIDObject ~= nil then
			local tycoon = toolsModule.GetTool(GUIDObject.Value)
			if tycoon then
				tycoon:Interface("RequestUpgrade",armourStandName,true,false)
			end
		end
	end)
else
	module.UpgradeRemote.OnServerEvent:Connect(function(player,GUIDObject,armourStandName)
		if GUIDObject ~= nil then
			local tycoon = toolsModule.GetTool(GUIDObject.Value)
			if tycoon then
				tycoon:Interface("RequestUpgrade",armourStandName,true,true)
			end
		end
	end)
end


return module
