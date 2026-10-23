local Data = {}
Data.__index = Data

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local helperFunctions = require(script.Parent.HelperFunctions)
local bank = require(script.Parent.Bank)

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local isServer = runService:IsServer()

local spawnableRewards = workspace.SpawnableRewards
local rewardZone = spawnableRewards.RewardZone

local allRewards = workspace.AllRewards
local vacuum = allRewards.Vacuum
local allRewardGUID = allRewards.GUID

local bias = 10
local rewardType = {"Cash"}

function Data.new(destroyable,globalRNG)
	local self = setmetatable({}, Data)

	self.Part = nil
	self.Model = nil
	self.Amount = 0
	self.GUIDObject = nil
	
	self.GlobalRNG = globalRNG
	
	self.Spawnable = true
	self.Destroyable = destroyable
	
	self.Next = nil
	
	self.TouchedPlayers = {}
	
	self.TouchEvent = nil

	return self
end

function Data:InsertPart(part)
	self.Part = part
	helperFunctions.SetSquareSize(part)
	self.TouchEvent = self.TouchEvent or self.Part.Touched:Connect(function(hit)
		if isServer then
			local player = players:GetPlayerFromCharacter(hit.Parent)
			if not player then return end

			local userId = player.UserId
			local amount = self.Amount
			local guidObject = self.GUIDObject
			local canCollect =  player and not self.TouchedPlayers[userId] and amount and guidObject

			if canCollect then
				self.TouchedPlayers[userId] = true
				bank.Bank:GiveRewardToPlayer(player,guidObject,amount)
			end
		else
			local player = players:GetPlayerFromCharacter(hit.Parent)
			if not player or player ~= players.LocalPlayer then return end
			
			self.Spawnable = false
		end
	end)
end

function Data:RemovePart()
	self.TouchEvent = self.TouchEvent and self.TouchEvent:Disconnect()
	self.Part = nil
end

function Data:Reset()
	if isServer then
		for _, player in ipairs(players:GetPlayers()) do
			local canClear = not self.TouchedPlayers[player.UserId] and self.GUIDObject and self.Amount
			if canClear then 
				bank.Bank:OweRewardToPlayer(player,self.GUIDObject,-self.Amount)
			end
		end

		table.clear(self.TouchedPlayers)
	else
		self.Model = self.Model and self.Model:Destroy()
		if self.Destroyable then
			self.Part = self.Part and self.Part.Parent and self.Part:Destroy()
			self:RemovePart()
		end
		self.Spawnable = true
	end
end

function Data:GetNextRNG()
	local rng = self.GlobalRNG[1]
	local rewardPath = "Rewards_"..rewardType[1].."_Default"
	self.Amount = math.max(1,math.floor((rng:NextNumber(0, 1) ^ bias) * rng:NextInteger(1, 1_000_001)))
	self.GUIDObject = allRewardGUID:FindFirstChild(rewardPath)
end

function Data:Restore()
	if isServer then
		for _, player in ipairs(players:GetPlayers()) do
			local canAdd = self.GUIDObject and self.Amount 
			if canAdd then
				bank.Bank:OweRewardToPlayer(player,self.GUIDObject,self.Amount)
			end
		end
	else
		if not self.Part or not self.Spawnable then return end
		local rewardTable = toolsModule.GetTool(self.GUIDObject.Value)
		local cFrame = self.Part.CFrame
		self.Model = rewardTable:Interface("GetModel",self.Part.CFrame,self.Amount)
		self.Model:PivotTo(self.Part.CFrame)
		self.Model.Parent = vacuum
	end
end

function Data:Destroy()

	table.clear(self)
	setmetatable(self, nil)
end

return Data
