local stand = require(script.Stand)
local billboard = require(script.Billboard)
local collectButton = require(script.CollectButton)
local upgradeButton = require(script.UpgradeButton)
local clientVisuals = require(script.ClientVisuals)
local suffix = require(script.Suffix)

local isClient = game:GetService("RunService"):IsClient()

local ArmourStand = {}
ArmourStand.__index = ArmourStand

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function ArmourStand.new(tycoonTable,armourStand)
	local self = setmetatable({}, ArmourStand)

	self.TycoonTable = tycoonTable
	self.ArmourStand = armourStand

	self.Stand = nil
	self.Billboard = nil
	self.UpgradeButton = nil
	self.CollectButton = nil
	self.ClientVisuals = nil

	self.EquipPrompt = nil
	self.EquipPromptTrigger = nil
	self.EquipPromptShown = nil
	self.SellPrompt = nil
	self.SellPromptTrigger = nil

	self.ChildAddedConnection = nil
	self.ChildRemovedConnection = nil

	return self
end

function ArmourStand:Init(player:Players?)
	local standModel = self.ArmourStand.Stand

	self.Armour = standModel.Armour

	local proximityPrompt = standModel.ProximityPrompt
	self.EquipPrompt = proximityPrompt.Equip
	self.SellPrompt = proximityPrompt.Sell
	self.EquipPrompt.Enabled = true
	self.SellPrompt.Enabled = true

	self.TycoonOwner = player
	
	self.Stand = self.Stand or stand.new(self.ArmourStand)
	self.Stand:Init(self.TycoonOwner)

	self.Billboard = self.Billboard or billboard.new(self.ArmourStand,self.Stand:GetArmourInterface())
	self.Billboard:Init(self.TycoonOwner)
	
	self.UpgradeButton = self.UpgradeButton or upgradeButton.new(self.ArmourStand,self.TycoonTable,self.Stand:GetArmourInterface())
	self.UpgradeButton:Init(self.TycoonOwner)

	self.CollectButton = self.CollectButton or collectButton.new(self.ArmourStand,self.Stand:GetArmourInterface())
	self.CollectButton:Init(self.TycoonOwner)
	
	self.ClientVisuals = self.ClientVisuals or clientVisuals.new(self.ArmourStand)
	self.ClientVisuals:Init(self.TycoonOwner)
	
	self.EquipPromptTrigger = self.EquipPromptTrigger and self.EquipPromptTrigger:Disconnect()
	self.SellPromptTrigger = self.SellPromptTrigger and self.SellPromptTrigger:Disconnect()
	
	if not self.TycoonOwner then
		self.Stand:ResetStand()
	else
		self:AddedOrRemoved(self.Stand:CreateArmour(),true)

		self.ChildAddedConnection = self.ChildAddedConnection or self.Armour.ChildAdded:Connect(function(child)
			self:AddedOrRemoved(child,true)
		end)

		self.ChildRemovedConnection = self.ChildRemovedConnection or self.Armour.ChildRemoved:Connect(function(child)
			self:AddedOrRemoved(child,false)
		end)

		self.EquipPromptTrigger = self.EquipPromptTrigger or self.EquipPrompt.Triggered:Connect(function(player)
			self:EquipProximityPrompt(player)
		end)
		
		self.SellPromptTrigger = self.SellPromptTrigger or self.SellPrompt.Triggered:Connect(function(player)
			self:SellProximityPrompt(player)
		end)
	end

	if isClient then
		self.EquipPrompt.Enabled = self.TycoonOwner and true or false
		self.SellPrompt.Enabled = self.TycoonOwner == game.Players.LocalPlayer
		
		self.EquipPromptShown = self.EquipPromptShown or self.EquipPrompt.PromptShown:Connect(function()
			self:UpdateProximityPromptText()
		end)
	end
	
	self.Billboard:UpdateText()
end

function ArmourStand:AddedOrRemoved(child,added)
	if not child then return end
	
	local toolTable = toolsModule.CreateTool(child)
	local className, _, _ = toolsModule.GetToolIdentifier(child)

	if className == "Armours" then
		if added then
			self.Stand:Added(toolTable)
		else
			self.Stand:Removed()
		end
		self.ClientVisuals:ChangeColor(added,self.Stand:GetRarity())
		self.UpgradeButton:UpdateText()
		self.Billboard:UpdateText()
		self:UpdateProximityPromptText()
	end
end

function ArmourStand:EquipProximityPrompt(player)
	if player == self.TycoonOwner then
		local allTools = toolsModule.GetAllTools(player.Character,{Armours = true})
		local armourData = allTools.Armours and allTools.Armours[1]
		
		self.CollectButton:Collect(true)
		self.Stand:GiveArmour(player,armourData)
	else
		self.Stand:PromptStealArmour(player)
	end
end

function ArmourStand:UpdateProximityPromptText()
	if isClient then
		if self.TycoonOwner == game.Players.LocalPlayer then
			if self.Stand:HasArmour() then
				self.EquipPrompt.ActionText = "Equip"
			else
				self.EquipPrompt.ActionText = "Place"	
			end
		else
			self.EquipPrompt.ActionText = "Steal"
		end
		
		self.SellPrompt.ActionText = "Sell: "..suffix.Shorten(self.Stand:GetSellPrice())
	end
end

function ArmourStand:SellProximityPrompt(player)
	if player == self.TycoonOwner then
		self.CollectButton:Collect(true)
		self.Stand:SellArmour()
	end
end

function ArmourStand:Upgrade()
	self.UpgradeButton:Upgrade()
	self.Billboard:UpdateText()
end

function ArmourStand:Rebirth()
	self.Stand:ResetStand(true)
end

function ArmourStand:HasArmour()
	return self.Stand:HasArmour()
end

function ArmourStand:InsertArmour(guidObject)
	self.Stand:InsertArmour(guidObject)
end

function ArmourStand:Destroy()
	self.ChildAddedConnection = self.ChildAddedConnection and self.ChildAddedConnection:Disconnect()
	self.ChildRemovedConnection = self.ChildRemovedConnection and self.ChildRemovedConnection:Disconnect()
	
	self.EquipPromptTrigger = self.EquipPromptTrigger and self.EquipPromptTrigger:Disconnect()
	self.SellPromptTrigger = self.SellPromptTrigger and self.SellPromptTrigger:Disconnect()
	
	self.Billboard = self.Billboard and self.Billboard:Destroy()
	self.UpgradeButton = self.UpgradeButton and self.UpgradeButton:Destroy()
	self.CollectButton = self.CollectButton and self.CollectButton:Destroy()
	self.ClientVisuals = self.ClientVisuals and self.ClientVisuals:Destroy()
	self.Stand = self.Stand and self.Stand:Destroy()
end

return ArmourStand