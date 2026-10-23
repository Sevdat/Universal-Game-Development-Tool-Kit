local safe = require(script.Safe)
local zone = require(script.Zone)

local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local ZoneManager = {}
ZoneManager.__index = ZoneManager

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function ZoneManager.new()
	local self = setmetatable({}, ZoneManager)

	self.Safe = nil
	self.Zone = nil

	return self
end

function ZoneManager:Init(zonePart,safeModel)
	self.Zone = self.Zone or zone.new()
	self.Zone:Init(zonePart)

	self.Safe = self.Safe or safe.new()
	self.Safe:Init(safeModel)
end

function ZoneManager:UpdateReward(armourPath)
	self.Safe:UpdateReward(armourPath)
end

function ZoneManager:UpdateColor(color)
	self.Zone:UpdateColor(color)
end

function ZoneManager:UpdateProgress(aliveNPCS,maxNPCS,dropReward)
	self.Safe:UpdateProgress(aliveNPCS,maxNPCS,dropReward)
end

function ZoneManager:UpdateCountdown(timeLeft)
	self.Zone:UpdateCountdown(timeLeft)
end

function ZoneManager:Enabled(enabled)
	self.Safe:Enabled(enabled)
	self.Zone:Enabled(enabled)
end

function ZoneManager:InsertTriggerFunction(func)
	self.Safe:InsertTriggerFunction(function()
		func()
		self:Enabled(false)
	end)
end


function ZoneManager:Destroy()

	table.clear(self)
end


return ZoneManager