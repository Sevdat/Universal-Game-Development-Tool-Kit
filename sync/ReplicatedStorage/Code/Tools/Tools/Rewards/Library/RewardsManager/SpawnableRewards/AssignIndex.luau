local module = {}
module.__index = module

local runService = game:GetService("RunService")
local isClient = runService:IsClient()
local isServer = runService:IsServer()

local spawnableRewards = workspace.SpawnableRewards
local rewardZone = spawnableRewards.RewardZone
local pool = spawnableRewards.Pool

local bonusIndex = 100

function module.new()
	local self = setmetatable({}, module)

	self.ProcessQueue = pool:GetChildren()
	self._processing = false
	
	self.IndexPool = {}

	self.MinIndex = 0
	self.FixedIndex = 0
	self.MaxIndex = 0
	
	if isServer then
		self.FixedIndex = #pool:GetChildren()
		pool:SetAttribute("Size",self.FixedIndex)
	else
		self.FixedIndex = pool:GetAttribute("Size")
	end

	self.MaxIndex = self.FixedIndex + bonusIndex

	for i = self.MaxIndex, 1, -1 do
		table.insert(self.IndexPool, i)
	end

	self.RewardZoneRemovedConnection = self.RewardZoneRemovedConnection or rewardZone.ChildRemoved:Connect(function(child)
		self:ReturnIndex(child)
	end)
	
	if isServer then
		self:StartQueue()
		self.PoolAddedConnection = self.PoolAddedConnection or pool.ChildAdded:Connect(function(child)
			self:StartQueue(child)
		end)
	end

	return self
end

function module:StartQueue(child)
	if child then
		table.insert(self.ProcessQueue,child)
	end

	if self._processing then return end

	self._processing = true

	while #self.ProcessQueue > 0 do
		local part = table.remove(self.ProcessQueue, 1)
		self:SetNextIndex(part)
	end

	self._processing = false
end

function module:SetNextIndex(part:Part)
	if #self.IndexPool == 0 then
		part:Destroy()
	else
		part.Name = table.remove(self.IndexPool)
		part.Parent = rewardZone
	end
end

function module:ReturnIndex(part:Part)
	table.insert(self, tonumber(part.Name))
end

function module:GetSize()
	return self.FixedIndex, self.MaxIndex
end

return module