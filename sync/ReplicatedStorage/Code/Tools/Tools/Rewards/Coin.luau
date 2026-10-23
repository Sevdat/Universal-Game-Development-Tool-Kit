local debris = game:GetService("Debris")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local rewardInterface = require(script.Parent.Library.RewardInterface)

local isClient = game:GetService("RunService"):IsClient()

local defaultName = "Default"

local Coin = {}
Coin.__index = Coin

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function Coin.new(config,guidObject)
	local self = setmetatable({}, Coin)

	self.Config = config

	self.GUIDObject = guidObject
	
	self.RewardInterface = rewardInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function Coin:Interface(functionName,...)
	if self._destroyed then return end
	return self.RewardInterface and self.RewardInterface:Call(functionName,...)
end

function Coin:Destroy()
	self._destroyed = true
	
	toolsModule.DestroyTool(self.GUIDObject)
end

return Coin