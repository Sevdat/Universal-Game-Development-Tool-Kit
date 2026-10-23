local ArmourInterface = {}
ArmourInterface.__index = ArmourInterface

local isStudio = game:GetService("RunService"):IsStudio()

local activeArmours = require(script.Parent.Remote).ActiveArmours

function ArmourInterface.new(armourModule)
	local self = setmetatable({}, ArmourInterface)
	self.ArmourModule = armourModule
	
	return self
end

function ArmourInterface:Call(functionName:string,...)
	if not self.ArmourModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	if isStudio then error("No function named: "..functionName) end
end

function ArmourInterface:Init(character,instantEquip)
	return self.ArmourModule:Init(character,instantEquip)
end

function ArmourInterface:Equip(equip:boolean,instantEquip:boolean?)
	return self.ArmourModule:Equip(instantEquip)
end

function ArmourInterface:GetName()
	return self.ArmourModule.Config.Name
end

function ArmourInterface:GetRarity()
	return self.ArmourModule.Config.Rarity
end

function ArmourInterface:GetLevel()
	return self.ArmourModule.Level
end

function ArmourInterface:GetHealth()
	local health = self.ArmourModule.Level*(self.ArmourModule.Config.MaxHealth / self.ArmourModule.Config.MaxLevel)
	return health + 100
end

function ArmourInterface:GetMaxLevel()
	return self.ArmourModule.Config.MaxLevel
end

function ArmourInterface:SetLevel(newLevel)
	self.ArmourModule.Level = newLevel or self.ArmourModule.Level
	return self.ArmourModule.Level
end

function ArmourInterface:GetMaxHealth()
	return self.ArmourModule.Config.MaxHealth
end

function ArmourInterface:GetIncome()
	return self.ArmourModule.Config.Income
end

function ArmourInterface:GetUpgradePrice()
	return self.ArmourModule.Config.UpgradePrice
end

function ArmourInterface:GetSell()
	return self.ArmourModule.Config.Sell
end

function ArmourInterface:Destroy()
	self.ArmourModule:Destroy()
end

return ArmourInterface