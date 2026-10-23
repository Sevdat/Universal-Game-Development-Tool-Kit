local module = {}

local isclient = game:GetService("RunService"):IsClient()

module.SetAimRemote = script.SetAimRemote
module.ShootRemote = script.ShootRemote
module.EquipRemote = script.EquipRemote
module.ReloadRemote = script.ReloadRemote

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

if isclient then
	module.SetAimRemote.OnClientEvent:Connect(function(GUIDObject,position:boolean,target:Part)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon then
				weapon:Interface("RequestSetAim",position,target,true,false)
			end
		end
	end)
else
	module.SetAimRemote.OnServerEvent:Connect(function(player,GUIDObject,position:boolean,target:Part)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon and weapon.Player == player then
				weapon:Interface("RequestSetAim",position,target,true,true)
			end
		end
	end)
end

if isclient then
	module.ShootRemote.OnClientEvent:Connect(function(GUIDObject,pullTrigger:boolean)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon then
				weapon:Interface("RequestShoot",pullTrigger,true,false)
			end
		end
	end)
else
	module.ShootRemote.OnServerEvent:Connect(function(player,GUIDObject,pullTrigger:boolean)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon and weapon.Player == player then
				weapon:Interface("RequestShoot",pullTrigger,true,true)
			end
		end
	end)
end

if isclient then
	module.EquipRemote.OnClientEvent:Connect(function(GUIDObject,isEquipped)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon then
				weapon:Interface("RequestEquip",isEquipped,true,false)
			end
		end
	end)
else
	module.EquipRemote.OnServerEvent:Connect(function(player,GUIDObject,isEquipped)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon and weapon.Player == player then
				weapon:Interface("RequestEquip",isEquipped,true,true)
			end
		end
	end)
end

if isclient then
	module.ReloadRemote.OnClientEvent:Connect(function(GUIDObject)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon then
				weapon:Interface("RequestReload",true,false)
			end
		end
	end)
else
	module.ReloadRemote.OnServerEvent:Connect(function(player,GUIDObject)
		if GUIDObject ~= nil then
			local weapon = toolsModule.GetTool(GUIDObject.Value)
			if weapon and weapon.Player == player then
				weapon:Interface("RequestReload",true,true)
			end
		end
	end)
end

--if isclient then
--	local localPlayer = game.Players.LocalPlayer
--	module.ShowDamageRemote.OnClientEvent:Connect(function(GUIDObject,position,hit, killed)
--		if GUIDObject ~= nil then
--			local weapon = toolsModule.GetTool(GUIDObject.Value)
--			if weapon then
--				weapon:Interface("VisualHit",position,hit, killed)
--			end
--		end
--	end)
--end

return module
