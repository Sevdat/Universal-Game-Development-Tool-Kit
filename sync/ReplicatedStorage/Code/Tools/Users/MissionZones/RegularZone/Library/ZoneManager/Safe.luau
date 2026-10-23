local billboard = require(script.Billboard)
local isServer = game:GetService("RunService"):IsServer()

local Safe = {}
Safe.__index = Safe

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local collectSound = script.water_charge
local openSound = script.Glitter

function Safe.new()
	local self = setmetatable({}, Safe)

	self.SafeModel = nil
	
	self.Billboard = nil
	self.PlaceReward = nil
	self.ProximityPrompt = nil

	self.Hinge = nil

	self.ArmourPath = nil
	self.RewardModel = nil
	
	self.TriggerFunction = nil
	self.CollectPromptTrigger = nil
	
	self.Progress = 0
	
	self.Humanoid = nil
	self.Animator = nil
	self.OpenSafeAnimation = nil
	self.OpenSafeAnimationTrack = nil
	
	self.CollectSound = nil

	return self
end

function Safe:Init(safeModel)
	self.SafeModel = safeModel
	
	self.Billboard = self.Billboard or billboard.new()
	self.Billboard:Init(self.SafeModel:FindFirstChild("Billboard"):FindFirstChild("Billboard"))
	
	self.PlaceReward = self.SafeModel.PlaceReward
	self.ProximityPrompt = self.SafeModel:FindFirstChild("ProximityPrompt"):FindFirstChild("Collect")

	self.Hinge = self.SafeModel:FindFirstChild("Hinge")
	
	self.Humanoid = self.SafeModel:FindFirstChild("Humanoid")
	self.Animator = self.Humanoid:FindFirstChild("Animator")
	self.OpenSafeAnimation = self.Animator:FindFirstChild("SafeOpen")

	self.OpenSafeAnimationTrack = self.OpenSafeAnimationTrack or self.Animator:LoadAnimation(self.OpenSafeAnimation)
	
	self.CollectSound = self.CollectSound or collectSound:Clone()
	self.CollectSound.Parent = self.SafeModel.PrimaryPart
	
	self.OpenSound = self.OpenSound or openSound:Clone()
	self.OpenSound.Parent = self.SafeModel.PrimaryPart
	
	if isServer then
		self.CollectPromptTrigger = self.CollectPromptTrigger or self.ProximityPrompt.Triggered:Connect(function(player)
			if self.TriggerFunction then
				self.TriggerFunction(player)
			end
		end)
	else
		self:UpdateReward(self.ArmourPath)
	end
end

function Safe:UpdateReward(armourPath:string)
	self.ArmourPath = armourPath
	self.RewardModel = self.RewardModel and self.RewardModel:Destroy()

	self.OpenSafeAnimationTrack:AdjustSpeed(1)
	if not self.ArmourPath or self.ArmourPath == "" then 
		self.Billboard:Enabled(false)
		return 
	end
	local _,_,configName = toolsModule.GetToolIdentifier(self.ArmourPath)
	
	local GUIDObject = workspace.AllRewards.GUID:FindFirstChild("Rewards_Armour_Default")
	local toolTable = toolsModule.GetTool(GUIDObject.Value)
	self.RewardModel = toolTable:Interface("GetModel",self.PlaceReward.WorldCFrame,configName,1)
	self.RewardModel.Parent = self.PlaceReward
	
	self.Billboard:Enabled(true)
end

function Safe:InsertTriggerFunction(func)
	self.TriggerFunction = func and function(player)
		if self.Progress ~= 1 or not self.ArmourPath or not self:Collect(player) then return end
		func()
		self.Billboard:Enabled(false)
	end
end

function Safe:UpdateProgress(aliveNPCS, maxNPCS,dropReward)
	self.Progress = 1-(aliveNPCS/maxNPCS)
	
	if self.Progress == 1 and not isServer then
		if dropReward then
			if self.OpenSound and self.OpenSafeAnimationTrack.Speed>0 then
				self.OpenSound:Play()
			end
			
			self.OpenSafeAnimationTrack:Play()

			self.OpenSafeAnimationTrack:GetMarkerReachedSignal("MidStop"):Connect(function(paramString)
				self.OpenSafeAnimationTrack:AdjustSpeed(0)
			end)
		end
	end
	self.Billboard:UpdateText(self.Progress)
end

function Safe:Collect(player)
	local stealerTycoonGUID = toolsModule.GetData(player,{"Tycoon","OwnedTycoon"}).Value
	local stealerTycoonTable = toolsModule.GetTool(stealerTycoonGUID)
	
	local armourTable = toolsModule.CreateTool(self.ArmourPath)

	stealerTycoonTable:InsertToArmourStand(armourTable.GUIDObject)
	
	if self.CollectSound then
		self.CollectSound:Play()
	end
	
	return true
end

function Safe:Enabled(enabled)
	self.Billboard:Enabled(enabled)
end


function Safe:Destroy()


	table.clear(self)
end


return Safe
