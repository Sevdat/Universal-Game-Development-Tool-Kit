local tween = require(script.Parent.Tween)
local suffix = require(script.Parent.Suffix)
local calculations = require(script.Parent.Calculations)
local spatialSounds = require(script.Parent.SpatialSounds)
local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local Button = {}
Button.__index = Button

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function Button.new(armourStand,getArmourInterface)
	local self = setmetatable({}, Button)

	self.TycoonOwner = nil

	self.ArmourStand = armourStand
	self.CollectPart = self.ArmourStand.Collect
	self.Sound = script.Sound:Clone()
	self.ParticleEmitter = script.ParticleEmitter:Clone()
	self.ParticleEmitter.Parent = self.CollectPart
	
	self.GetArmourInterface = getArmourInterface
	
	self.Money = self.CollectPart.SurfaceGui.Money
	
	self.OfflineMoney = self.CollectPart.SurfaceGui.OfflineMoney
	self.TweenCompleted = function() return true end
	
	self.CollectPartTouched = self.CollectPart.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = game.Players:GetPlayerFromCharacter(character)

		if player == self.TycoonOwner and self.TweenCompleted() then
			self:Collect()
		end
	end)
	
	local textUpdate = 0
	
	self.LoopFunction = self.LoopFunction or function(dt)
		if textUpdate >= 1 then
			self:UpdateText()
			textUpdate = 0
		end
		textUpdate += dt
	end
	
	toolsModule.AddToLoop("Heartbeat",self.LoopFunction)

	return self
end

function Button:Init(tycoonOwner)
	self.TycoonOwner = tycoonOwner
end

function Button:CalculateSalary()
	local timePassed = toolsModule.GetData(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name,"CollectButtonTime"})
	if timePassed then
		local income = self.GetArmourInterface("GetIncome") or 0
		local level = self.GetArmourInterface("GetLevel") or 1
		return calculations.GetMoneySince(timePassed.Value,income,level,1)
	else
		return 0
	end
end

function Button:UpdateText()
	self.Money.Text = suffix.Shorten(self:CalculateSalary())
end

function Button:Collect(disableEffects)
	local timePassed = toolsModule.GetData(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name,"CollectButtonTime"})
	local cash = toolsModule.GetData(self.TycoonOwner,{"Player","Cash"})
	if not timePassed or not cash then return end
	
	local income = self:CalculateSalary()
	cash.Value += income
	timePassed.Value = os.time()
	
	if isClient then
		if not disableEffects then
			self.TweenCompleted = tween.TweenCollectButton(self.CollectPart,self.ParticleEmitter)
			spatialSounds.Play3DSound(self.Sound,self.CollectPart)
		end
		
		toolsModule.UpdateData(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name,"CollectButtonTime"},os.time())
		if timePassed then
			self.Money.Text = "$"..0
		end
	end
end

function Button:Destroy()
	self.CollectPart = nil
	self.Sound:Destroy()
	self.ParticleEmitter:Destroy()
	self.Money = nil
	self.OfflineMoney = nil
	self.TweenCompleted = nil
	
	self.CollectPartTouched:Disconnect()
	self.CollectPartTouched = nil
	
	toolsModule.RemoveFromLoop("Heartbeat",self.LoopFunction)
	
	table.clear(self)
	setmetatable(self, nil)
end




return Button