local module = {}

local isclient = game:GetService("RunService"):IsClient()

module.ShootRemote = script.ShootRemote
module.ReloadRemote = script.ShootRemote

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

if isclient then
	module.ShootRemote.OnClientEvent:Connect(function(GUIDObject,to)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon then
				weapon:Shoot(to)
			end
		end
	end)
else
	module.ShootRemote.OnServerEvent:Connect(function(player,GUIDObject,to)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon and weapon.Player == player then
				module.ShootRemote:FireAllClients(GUIDObject,to)
				weapon:Shoot(to)
			end
		end
	end)
end

if isclient then
	module.ReloadRemote.OnClientEvent:Connect(function(GUIDObject)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon then
				weapon:Reload()
			end
		end
	end)
end

return module
