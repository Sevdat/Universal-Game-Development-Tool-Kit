local tween = require(script.Parent.Tween)
local suffix = require(script.Parent.Suffix)
local calculations = require(script.Parent.Calculations)
local spatialSounds = require(script.Parent.SpatialSounds)
local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local localPlayer = isClient and game.Players.LocalPlayer

local upgradeRemote = script.Parent.Parent.Remote.UpgradeRemote

local UpgradeButton = {}
UpgradeButton.__index = UpgradeButton

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function UpgradeButton.new(armourStand,tycoonTable,getArmourInterface)
	local self = setmetatable({}, UpgradeButton)

	self.TycoonOwner = nil
	
	self.ArmourStand = armourStand

	self.UpgradePart = self.ArmourStand.Stand.Upgrade
	self.UpgradeButton = self.UpgradePart.SurfaceGui.TextButton
	self.UpgradePrice = self.UpgradeButton.UpgradePrice
	self.UpgradeLevel = self.UpgradeButton.UpgradeLevel
	self.On = self.UpgradeButton.BackGround.On
	self.Off = self.UpgradeButton.BackGround.Off
	self.Tween = function() end
	
	self.Sound = script.Sound
	
	self.TycoonTable = tycoonTable
	
	self.GetArmourInterface = getArmourInterface
	
	self.UpgradeButtonTouched = self.UpgradeButton.MouseButton1Click:Connect(function()
		if self.TycoonOwner and localPlayer == self.TycoonOwner then 
			self.TycoonTable:Interface("RequestUpgrade",self.ArmourStand.Name,false,true)
		end
	end)

	return self
end

function UpgradeButton:Init(tycoonOwner)
	self.TycoonOwner = tycoonOwner
end

function UpgradeButton:SetOrIncrementArmourLevel()
	local armourLevel = toolsModule.GetData(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name,"Level"})
	if armourLevel then
		local currentLevel = self.GetArmourInterface("SetLevel",armourLevel.Value + (isClient and 0 or 1))
		if currentLevel then
			armourLevel.Value = currentLevel
		end
	end
end

function UpgradeButton:CalculateUpgradePrice()
	local upgradePrice = self.GetArmourInterface("GetUpgradePrice") or 0
	local level = self.GetArmourInterface("GetLevel") or 1
	return calculations.CalculateUpgradePrice(upgradePrice,level)
end

function UpgradeButton:Upgrade()	
	local cash = toolsModule.GetData(self.TycoonOwner,{"Player","Cash"})
	if not cash then return end
	
	local upgradePrice = self:CalculateUpgradePrice()
	
	if not upgradePrice then return end

	if cash.Value >= upgradePrice then
		if not isClient then
			cash.Value -= upgradePrice
		end
		
		self:SetOrIncrementArmourLevel()
		
		if isClient then
			self.Tween() 
			self.Tween = tween.TweenUpgradeButton(self.UpgradePart)
			spatialSounds.Play3DSound(self.Sound,self.UpgradePart)
			self:UpdateText()
		end
	end
end

function UpgradeButton:UpdateText()
	self.UpgradePrice.Text = suffix.Shorten(self:CalculateUpgradePrice())

	local currentLevel = self.GetArmourInterface("GetLevel") or 1
	self.UpgradeLevel.Text = "Level "..currentLevel .. ">" .."Level ".. currentLevel+1
end


function UpgradeButton:Destroy()
	self.UpgradePart = nil
	self.UpgradeButton = nil
	self.UpgradePrice = nil
	self.UpgradeLevel = nil
	self.On = nil
	self.Off = nil
	self.Tween = nil
	
	self.UpgradeButtonTouched:Disconnect()
	self.UpgradeButtonTouched = nil
	
	table.clear(self)
	setmetatable(self, nil)
end

return UpgradeButton