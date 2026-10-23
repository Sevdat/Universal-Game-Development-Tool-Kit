local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local SpawnableRewards = {}
SpawnableRewards.__index = SpawnableRewards

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local assignIndex = require(script.AssignIndex)
local assignReward = require(script.AssignReward)

local bias = 2 
local rewardType = {"Cash"}

function SpawnableRewards.new()
	local self = setmetatable({}, SpawnableRewards)

	self.AssignIndex = nil
	self.AssignReward = nil

	self.LoopFunction = nil

	return self
end

function SpawnableRewards:Init()
	self.AssignIndex = assignIndex.new()
	self.AssignReward = assignReward.new(self.AssignIndex:GetSize())
	
	self.LoopFunction = self.LoopFunction or function(dt)
		self.AssignReward:Loop(dt)
	end
	
	self.AssignReward:Loop(1/60)
	toolsModule.AddToLoop("Heartbeat",self.LoopFunction)
end

function SpawnableRewards:Destroy()

	table.clear(self)
	setmetatable(self, nil)
end

return SpawnableRewards
