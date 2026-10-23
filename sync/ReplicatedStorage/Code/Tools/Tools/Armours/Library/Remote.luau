local module = {}

local isclient = game:GetService("RunService"):IsClient()

module.EquipRemote = script.Equip

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

if isclient then
	module.EquipRemote.OnClientEvent:Connect(function(GUIDObject)
		if GUIDObject ~= nil then
			local armour = toolsModule.GetTool(GUIDObject.Value)
			if armour then
				armour:Interface("Equip",true)
			end
		end
	end)
else
	module.EquipRemote.OnServerEvent:Connect(function(player,GUIDObject)
		if GUIDObject ~= nil then
			local armour = toolsModule.GetTool(GUIDObject.Value)
			if armour and armour.Player == player then
				module.EquipRemote:FireAllClients(GUIDObject)
			end
		end
	end)
end



return module
