local isClient = game:GetService("RunService"):IsClient()
local npcSearch = require(script.NPCSearch)

local npcManager = {}
npcManager.__index = npcManager

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function npcManager.new(missionZoneTable, values)
	local self = setmetatable({}, npcManager)

	self.Values = values
	self.AliveNPCS = self.Values.AliveNPCS
	self.Countdown = self.Values.Countdown
	self.Active = self.Values.Active
	
	self.MissionZoneTable = nil

	self.DropRewardFlag = false

	self.NPCSFolder = nil
	self.LoopNPCFlag = false
	self.LoopNPCStopFlag = false
	self.NPCLoopStopCountDown = 3
	
	self.ZonePart = nil

	return self
end

function npcManager:Init(zonePart)
	self.ZonePart = zonePart
	self.NPCSFolder = isClient and self.Values:FindFirstChild("NPCS") or npcSearch.GetNPCSInZoneFolder(self.ZonePart,self.Values)
end

function npcManager:RespawnZone()
	npcSearch.RespawnNPCSInZone(self.NPCSFolder)
	self.DropRewardFlag = true
	
	if isClient then return end

	self.Countdown.Value = workspace:GetServerTimeNow() + math.random(30,70)
	self.AliveNPCS.Value = #self.NPCSFolder:GetChildren()
end

function npcManager:DespawnZone()
	npcSearch.DespawnNPCSInZone(self.NPCSFolder)
	self.DropRewardFlag = false

	if isClient then return end

	self.Countdown.Value = workspace:GetServerTimeNow() + 6
	self.AliveNPCS.Value = 0
end

function npcManager:CanDropReward()
	return self.DropRewardFlag
end

function npcManager:NPCKilled()	
	self.AliveNPCS.Value = math.clamp(self.AliveNPCS.Value-1,0,math.huge)
end

function npcManager:ActivateLoop()
	local active = self.AliveNPCS.Value>0
	self.LoopNPCFlag = active
	self.LoopNPCStopFlag = active
	self.NPCLoopStopCountDown = active and 3 or 0
end

function npcManager:Progress()
	local npcFolder = self.Values:FindFirstChild("NPCS")
	local maxNPCS = npcFolder and #npcFolder:GetChildren() or 1
	return self.AliveNPCS.Value,maxNPCS,self.DropRewardFlag
end

function npcManager:Loop(dt,humanoidRootParts)
	if not isClient then
		if self.Countdown.Value - workspace:GetServerTimeNow() <= 0 then
			self.Active.Value = not self.Active.Value
		end
	end
	
	if self.Active.Value then
		if not self.LoopNPCFlag and self.LoopNPCStopFlag then
			self.NPCLoopStopCountDown -= dt
			self.LoopNPCStopFlag = self.NPCLoopStopCountDown >= 0
			npcSearch.LoopNPCSInZone(self.NPCSFolder,dt,humanoidRootParts)
		elseif self.LoopNPCFlag then
			npcSearch.LoopNPCSInZone(self.NPCSFolder,dt,humanoidRootParts)
			self.LoopNPCFlag = false
		end
	end
end

function npcManager:Destroy()
	if self._destroyed then return end
	self._destroyed = true

end

return npcManager