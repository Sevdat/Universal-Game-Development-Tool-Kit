local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local isClient = game:GetService("RunService"):IsClient()
local localPlayer = isClient and game.Players.LocalPlayer or nil

local tween = require(script.Parent.Library.Tween)
local targetLockInterface = require(script.Parent.Library.TargetLockInterface)
local delock = require(script.Parent.Library.Delock)
local raycast = require(script.Parent.Library.Raycast)

local repeatLocking = 2

local TargetLock = {}
TargetLock.__index = TargetLock

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function TargetLock.new(config,guidObject)
	local self = setmetatable({}, TargetLock)

	self.Config = config
	
	self.Player = nil
	self.Character = nil

	self.TargetLockBillboard = nil
	
	self.Position = nil
	self.Target = nil
	self.ToolTable = nil
	
	self.Tween = nil

	self.LoopFunction = nil

	self.GUIDObject = guidObject
	
	self.TargetLockInterface = targetLockInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function TargetLock:Init(player,character)
	self.Player = player
	self.Character = character
	
	self.GUIDObject.Parent = character
	
	self.LockedSound = self.Config.LockedSound
	self.LockingSound = self.Config.LockingSound
	
	self.TargetLockBillboard = self.TargetLockBillboard or self.Config.TargetLockBillboard:Clone()
	self.TargetLockBillboard.Parent = workspace
	
	self.Tween = self.Tween or tween.new(self.TargetLockBillboard,self.LockingSound,self.LockedSound)
	
	local count = 0

	self.LoopFunction = self.LoopFunction or function(dt)
		count += dt
		if count < 0.05 then return end
		
		self:UpdateVisuals()
		
		count = 0
	end
	
	self:TriggerLoop(true)
end

function TargetLock:TriggerLoop(enable)
	if not isClient or self.Player ~= localPlayer then return end
	
	if enable then
		toolsModule.AddToLoop("Heartbeat",self.LoopFunction)
	else
		toolsModule.RemoveFromLoop("Heartbeat",self.LoopFunction)
	end
end

function TargetLock:UpdateVisuals()
	local getPosition = true
	local getTargetModel = not self.Target and true or false
	local getToolTable = not self.ToolTable and true or false
	
	local position,targetModel,toolTable = raycast.GetRayResult(getPosition,getTargetModel,getToolTable)
	
	self.Position = position
	
	self.Target = self.Target or targetModel
	self.Target = self.Target and delock.CanLock(self.Target.PrimaryPart) and self.Target or nil
	
	self.ToolTable = self.ToolTable or toolTable
	if self.ToolTable then
		self.ToolTable:Interface("SetVisibility",self.Target and true or false)
	end
	self.ToolTable = self.Target and self.ToolTable or nil 
	
	local tween = self.Target and self.Tween:Lock() or self.Tween:Reset()
	
	self.TargetLockBillboard.Adornee = self.Target and self.Target.PrimaryPart or nil
	self.TargetLockBillboard.Enabled = self.Target and true or false
end

function TargetLock:GetTargetPosition()
	local position = self.Target and self.Target.PrimaryPart.Position or self.Position
	return position,self.Target
end

function TargetLock:Interface(functionName,...)
	if self._destroyed then return end
	return self.TargetLockInterface and self.TargetLockInterface:Call(functionName,...)
end

function TargetLock:Destroy()
	self._destroyed = true
	
	self:TriggerLoop(false)
	
	self.Tween = self.Tween and self.Tween:Destroy()
	
	self.TargetLockBillboard = self.TargetLockBillboard and self.TargetLockBillboard:Destroy()
	
	toolsModule.DestroyTool(self.GUIDObject)
end

return TargetLock