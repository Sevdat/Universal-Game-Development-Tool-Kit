local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

local visuals = require(script.Parent.Library.Visuals)
local playerInterface = require(script.Parent.Library.PlayerInterface)
local backPack = require(script.Parent.Library.Backpack)
local remote = require(script.Parent.Library.Remote)

local isClient = game:GetService("RunService"):IsClient()

local defaultName = "Default"

local Player = {}
Player.__index = Player

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function Player.new(config,guidObject)
	local self = setmetatable({}, Player)

	self.Config = config

	self.Player = nil
	self.Character = nil
	self.HumanoidRootPart = nil
	self.Humanoid = nil

	self.Bounty = nil
	self.DamageMultiplier = nil

	self.BackPack = nil

	self.GUIDObject = guidObject
	
	self.Visuals = nil
	
	self.ChildAddedConnection = nil
	self.ChildRemovedConnection = nil
	
	self.PlayerInterface = playerInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)

	return self
end

function Player:Init(player)
	self.Player = player
	self.Character = player.Character
	self.Humanoid = self.Character.Humanoid
	self.HumanoidRootPart = self.Character.HumanoidRootPart
	
	self.GUIDObject.Parent = self.Character
	toolsModule.SetToolAttribute(self.Character,self.GUIDObject.Value)
	
	self.Visuals = visuals.new(self.Player)
	self.Visuals:Init(self.Character,self.Humanoid,self.HumanoidRootPart)

	self.Bounty = 0
	self.DamageMultiplier = 0
	
	self.BackPack = backPack.new(self.Player)

	self.ChildAddedConnection = self.ChildAddedConnection or self.Character.ChildAdded:Connect(function(child)
		self:RefreshTools(child,true)
	end)

	self.ChildRemovedConnection = self.ChildRemovedConnection or self.Character.ChildRemoved:Connect(function(child)
		self:RefreshTools(child,false)
	end)
end

function Player:RefreshTools(child,added:boolean,initilized:boolean)
	self.BackPack:RefreshTools(child,added,initilized)
end

function Player:Interface(functionName,...)
	if self._destroyed then return end
	return self.PlayerInterface and self.PlayerInterface:Call(functionName,...)
end

function Player:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	
	self.ChildAddedConnection = self.ChildAddedConnection and self.ChildAddedConnection:Disconnect()
	self.ChildRemovedConnection = self.ChildRemovedConnection and self.ChildRemovedConnection:Disconnect()
	
	self.BackPack = self.BackPack and self.BackPack:Destroy()
	
	self.Visuals = self.Visuals and self.Visuals:Destroy()
	
	toolsModule.DestroyTool(self.GUIDObject)
end

return Player