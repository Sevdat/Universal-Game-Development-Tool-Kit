local debris = game:GetService("Debris")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local rewardInterface = require(script.Parent.Library.RewardInterface)

local isClient = game:GetService("RunService"):IsClient()

local defaultName = "Default"

local Cash = {}
Cash.__index = Cash

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function Cash.new(config,guidObject)
	local self = setmetatable({}, Cash)

	self.Config = config

	self.GUIDObject = guidObject
	
	self.RewardInterface = rewardInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function Cash:Interface(functionName,...)
	if self._destroyed then return end
	return self.RewardInterface and self.RewardInterface:Call(functionName,...)
end

function Cash:Destroy()
	self._destroyed = true
	
	toolsModule.DestroyTool(self.GUIDObject)
end

return Cash