local RewardInterface = {}
RewardInterface.__index = RewardInterface

local players = game:GetService("Players")
local isStudio = game:GetService("RunService"):IsStudio()
local isClient = game:GetService("RunService"):IsClient()

local hrpSearch = require(script.Parent.Parent.Library.HRPSearch)
local rewardsManager = require(script.Parent.RewardsManager)

local remote = require(script.Parent.Remote)
local activeRewards = remote.ActiveRewards

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function RewardInterface.new(rewardModule)
	local self = setmetatable({}, RewardInterface)
	self.RewardModule = rewardModule
	
	return self
end

function RewardInterface:Call(functionName:string,...)
	if not self.RewardModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	
	if isStudio then error("No function named: "..functionName) end
end

function RewardInterface:Init(model,despawnAuraTime)
	self.RewardModule:Init(model,despawnAuraTime)
end

function RewardInterface:GetModel(cFrame,name:string?,amount:number?)
	
	name = name or "Default"
	amount = amount or 1
	
	local cloneModel = self.RewardModule.Config.GetRewards(name,amount):Clone()
	cloneModel:PivotTo(cFrame)

	return cloneModel
end

function RewardInterface:DropReward(position:Vector3)
	rewardsManager.DropReward(position)
end

function RewardInterface:Destroy()
	self.RewardModule:Destroy()
end

return RewardInterface