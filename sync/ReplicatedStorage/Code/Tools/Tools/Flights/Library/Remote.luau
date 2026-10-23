local module = {}

local isclient = game:GetService("RunService"):IsClient()

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

module.TriggerFlightRemote = script.TriggerFlightRemote

if isclient then
	module.TriggerFlightRemote.OnClientEvent:Connect(function(GUIDObject,isFlying)
		if GUIDObject ~= nil then
			local flight = toolsModule.GetTool(GUIDObject.Value)
			if flight then
				flight:Interface("RequestFlight",isFlying,true,false)
			end
		end
	end)
else
	module.TriggerFlightRemote.OnServerEvent:Connect(function(player,GUIDObject,isFlying)
		if GUIDObject ~= nil then
			local flight = toolsModule.GetTool(GUIDObject.Value)
			if flight and flight.Player == player then
				flight:Interface("RequestFlight",isFlying,true,true)
			end
		end
	end)
end



return module
