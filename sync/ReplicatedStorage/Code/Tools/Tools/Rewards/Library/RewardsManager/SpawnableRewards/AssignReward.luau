local module = {}
module.__index = module

local runService = game:GetService("RunService")
local isClient = runService:IsClient()
local isServer = runService:IsServer()

local helperFunctions = require(script.HelperFunctions)

local spawnableRewards = workspace.SpawnableRewards
local rewardZone = spawnableRewards.RewardZone
local pool = rewardZone

local data = require(script.Data)

function module.new(fixedIndex, maxIndex)
	local self = setmetatable({}, module)

	self.FixedIndex = fixedIndex
	self.MaxIndex = maxIndex
	
	self.CurrentTime = os.time()
	self.LastMinute = math.floor(self.CurrentTime - (self.CurrentTime % 60))
	self.GlobalRNG = {Random.new(self.LastMinute)}
	
	self.SpawnTask = nil

	self.RewardData = {}
	
	for index = 1, self.MaxIndex do
		local destroyable = self.FixedIndex < index
		self.RewardData[index] = self.RewardData[index] or data.new(destroyable,self.GlobalRNG)
		self:Refresh(index)
		self:Restore(index)
	end
	
	self.RewardZoneAddedConnection = self.RewardZoneAddedConnection or rewardZone.ChildAdded:Connect(function(child)
		self:OnAdded(child)
	end)
	
	self.RewardZoneRemovedConnection = self.RewardZoneRemovedConnection or rewardZone.ChildRemoved:Connect(function(child)
		self:OnRemove(child)
	end)
	
	self:Loop(0)

	return self
end

function module:Loop(dt)
	helperFunctions.Vacumm(dt)
	self.CurrentTime += dt

	if self.CurrentTime <= self.LastMinute + 60 then return end
	
	self.LastMinute = math.floor(self.CurrentTime - (self.CurrentTime % 60))

	self.GlobalRNG[1] = Random.new(self.LastMinute)
	
	dt = dt/2
	
	self.SpawnTask = self.SpawnTask and task.cancel(self.SpawnTask) or task.spawn(function()
		local count = 0
		for index = 1, self.MaxIndex do
			self:Refresh(index)
			self:Reset(index)
			
			if count<=10 then
				count += 1
			else
				count = 0
				task.wait()
			end
		end
		
		count = 0
		
		for index = 1, self.MaxIndex do
			self:Restore(index)
			
			if count<=10 then
				count += 1
			else
				count = 0
				task.wait()
			end
		end
	end)
end

function module:Refresh(index)
	local rewardData = self.RewardData[index]
	local part = rewardZone:FindFirstChild(index)
	if part then
		rewardData:InsertPart(part)
	else
		rewardData:RemovePart(part)
	end
end

function module:Reset(index)
	local rewardData = self.RewardData[index]
	rewardData:Reset()
end

function module:Restore(index)
	local rewardData = self.RewardData[index]
	rewardData:GetNextRNG()
	rewardData:Restore()
end

function module:OnAdded(part)
	local index = tonumber(part.Name)
	local rewardData = self.RewardData[index]
	local part = rewardZone:FindFirstChild(index)
	rewardData:InsertPart(part)
	rewardData:Restore()
end

function module:OnRemove(part)
	local index = tonumber(part.Name)
	local rewardData = self.RewardData[index]
	local part = rewardZone:FindFirstChild(index)
	rewardData:RemovePart(part)
	rewardData:Reset()
end

return module