local debris = game:GetService("Debris")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")

local isClient = game:GetService("RunService"):IsClient()

local bodyData = require(script.Parent.BodyData)
local armourPartMotion = require(script.ArmourPartMotion)
local properties = require(script.Properties)
local homingCast = require(script.ArmourPartMotion.Library.HomingCast)

local ArmourPart = {}
ArmourPart.__index = ArmourPart

function ArmourPart.new(armour)
	local self = setmetatable({}, ArmourPart)
	
	self.Armour = armour
	
	self.BodyPart = nil
	self.ArmourPart = nil

	self.Equipping = nil

	return self
end

function ArmourPart:Init(bodyPart:Part,instantEquip)
	if not isClient or not self.Armour then return end
	
	self.BodyPart = bodyPart or self.BodyPart
	
	if not self.BodyPart then return end

	self.ArmourPart = self.ArmourPart and self.ArmourPart.Parent and self.ArmourPart or nil
	self.ArmourPart = self.ArmourPart or self.BodyPart and self.Armour[self.BodyPart.Name]:Clone()
	if not self.ArmourPart then return end
	
	self:Equip(false)
	
	self.ArmourPart.Parent = self.BodyPart
	
	self:Equip(true,instantEquip)
end

function ArmourPart:Equip(equip:boolean,instantEquip:boolean?)
	if not self.ArmourPart or not self.BodyPart then return end
	
	if equip and instantEquip then
		properties.WeldParts(self.ArmourPart,self.BodyPart)
		return
	end
	
	properties.UnweldParts(self.ArmourPart)
	
	if equip then
		self.ArmourPart.Anchored = true
		self.Equipping = self.Equipping or armourPartMotion.Linear.FlyToTarget(self,self.ArmourPart,self.BodyPart)
	else
		self.ArmourPart.Anchored = false
		self.Equipping = self.Equipping and homingCast.TerminateProjectile(self.Equipping) and nil
	end
end

function ArmourPart:OnHealthChange(currentHealth,maxHealth,instantEquip)
	if not isClient or not self.BodyPart then return end

	local ratio = currentHealth/maxHealth
	local canDestroy = bodyData.DestroyOnHealth[self.BodyPart.Name] > ratio
	
	if self.ArmourPart and canDestroy then
		self:Equip(false)
		debris:AddItem(self.ArmourPart,10)
		self.ArmourPart = nil
	elseif not self.ArmourPart and not canDestroy then
		self:Init(self.BodyPart)
		self:Equip(true,instantEquip)
	end
end

function ArmourPart:Destroy()	
	self:Equip(false)
	
	self.Armour = nil

	self.BodyPart = nil
	
	self.ArmourPart = self.ArmourPart and self.ArmourPart:Destroy()
end

return ArmourPart