local MissionZoneInterface = {}
MissionZoneInterface.__index = MissionZoneInterface

local isStudio = game:GetService("RunService"):IsStudio()
local isServer = game:GetService("RunService"):IsServer()

local dropRewardRemote = require(script.Parent.Remote).DropRewardRemote

local activeMissionZones = require(script.Parent.Remote).ActiveMissionZones

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function MissionZoneInterface.new(rewardModule)
	local self = setmetatable({}, MissionZoneInterface)
	self.MissionZoneModule = rewardModule
	
	return self
end

function MissionZoneInterface:Call(functionName:string,...)
	if not self.MissionZoneModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	
	if isStudio then 
		error("No function named: "..functionName)
	end
end

function MissionZoneInterface:Init(model,despawnAuraTime)
	self.MissionZoneModule:Init(model,despawnAuraTime)
end

function MissionZoneInterface:GetArea()
	return self.MissionZoneModule.ZonePart
end

function MissionZoneInterface:DropReward()
	self.MissionZoneModule:DropReward()
	if isServer then
		dropRewardRemote:FireAllClients(self.MissionZoneModule.GUIDObject)
	end
end


function MissionZoneInterface:NPCKilled()
	self.MissionZoneModule:NPCKilled()
end

function MissionZoneInterface:CollectReward(player)
	self.MissionZoneModule:CollectReward(player)
end

function MissionZoneInterface:LoopMissionZone(dt)
	self.MissionZoneModule:LoopMissionZone(dt)
end

function MissionZoneInterface:ActivateNPCLoop()
	self.MissionZoneModule:ActivateNPCLoop()
end

function MissionZoneInterface:AddHRPInZone(player,hrp)
	self.MissionZoneModule:AddHRPInZone(player,hrp)
end

function MissionZoneInterface:Destroy()
	self.MissionZoneModule:Destroy()
end

return MissionZoneInterface