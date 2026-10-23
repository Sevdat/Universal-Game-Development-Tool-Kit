local debris = game:GetService("Debris")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local missionZoneInterface = require(script.Parent.Library.MissionZoneInterface)
local npcManager = require(script.Parent.Library.NPCManager)
local rewardsManager = require(script.Parent.Library.RewardsManager)
local zoneManager = require(script.Library.ZoneManager)

local isClient = game:GetService("RunService"):IsClient()

local RegularZone = {}
RegularZone.__index = RegularZone

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function RegularZone.new(config,guidObject)
	local self = setmetatable({}, RegularZone)

	self.Config = config

	self.ZonePart = nil
	
	self.Values = nil
	self.Active = nil
	self.Countdown = nil
	self.AliveNPCS = nil
	self.WinReward = nil
	
	self.NPCManager = nil
	self.ZoneManager = nil

	self.GUIDObject = guidObject
	
	self.ActiveConnection = nil
	self.WinRewardConnection = nil
	self.AliveNPCSConnection = nil
	
	self.LastClearTime = nil
	self.HRPSInZone = nil
	
	self.MissionZoneInterface = missionZoneInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function RegularZone:Init(zoneModel)
	self.ZonePart = zoneModel.ActivationZone
	
	self.Values = zoneModel.Values
	self.Active = self.Values.Active
	self.Countdown = self.Values.Countdown
	self.AliveNPCS = self.Values.AliveNPCS
	self.WinReward = self.Values.WinReward
	
	self.NPCManager = self.NPCManager or npcManager.new(self, self.Values)
	self.NPCManager:Init(self.ZonePart)
	
	self.ZoneManager = self.ZoneManager or zoneManager.new()
	self.ZoneManager:Init(self.ZonePart,zoneModel.Safe)

	self:UpdateZone(self.Active.Value)
	self.ActiveConnection = self.ActiveConnection or self.Active.Changed:Connect(function(value)
		self:UpdateZone(value)
	end)
	
	self.ZoneManager:UpdateReward(self.WinReward.Value)
	self.WinRewardConnection = self.WinRewardConnection or self.WinReward.Changed:Connect(function(value)
		self.ZoneManager:UpdateReward(value)
	end)

	self.ZoneManager:UpdateProgress(self.NPCManager:Progress())
	self.AliveNPCSConnection = self.AliveNPCSConnection or self.AliveNPCS.Changed:Connect(function(value)
		self.ZoneManager:UpdateProgress(self.NPCManager:Progress())
	end)
	
	self.ZoneManager:InsertTriggerFunction(function() 
		self:RollWinReward(false)
	end)
	
	self.LastClearTime = os.time() + 3
	self.HRPSInZone = {}
	
	toolsModule.SetToolAttribute(zoneModel,self.GUIDObject.Value)
end

function RegularZone:RollWinReward(enabled:boolean)
	if isClient then return end
	
	if enabled then
		local armourPath,color = rewardsManager.RollWinReward()
		self.ZoneManager:UpdateColor(color)
		self.WinReward.Value = armourPath
	else
		self.WinReward.Value = ""
	end
end

function RegularZone:UpdateZone(enabled)
	if enabled then 
		self.NPCManager:RespawnZone()
	else 
		self.NPCManager:DespawnZone() 
	end
	self:RollWinReward(enabled)
	self.ZoneManager:Enabled(enabled)
end

function RegularZone:NPCKilled()	
	self.NPCManager:NPCKilled()	
end

function RegularZone:DropReward()	
	self.NPCManager:DropReward()
	self:RollWinReward(false)
	self.Active.Value = false
	self:ActivateNPCLoop()
end

function RegularZone:ActivateNPCLoop()
	self.NPCManager:ActivateLoop()
end

function RegularZone:AddHRPInZone(player,hrp)
	local currentTime = os.time()
	local nextTime = currentTime + 3
	
	self.LastClearTime = self.LastClearTime or currentTime
	self.HRPSInZone = self.HRPSInZone or {}
	
	if self.LastClearTime < currentTime then 
		table.clear(self.HRPSInZone)
		self.LastClearTime = nextTime
	end
	
	self.HRPSInZone[player.UserId] = hrp
end

function RegularZone:LoopMissionZone(dt)
	if isClient then
		local timeLeft = math.clamp(math.ceil(self.Countdown.Value - workspace:GetServerTimeNow()),0,math.huge)
		self.ZoneManager:UpdateCountdown(timeLeft)
	end
	
	if self.HRPSInZone then
		self.NPCManager:Loop(dt, self.HRPSInZone)
	end
end

function RegularZone:Interface(functionName,...)
	if self._destroyed then return end
	return self.MissionZoneInterface and self.MissionZoneInterface:Call(functionName,...)
end

function RegularZone:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	
	toolsModule.DestroyTool(self.GUIDObject)
end

return RegularZone