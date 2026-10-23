local debris = game:GetService("Debris")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")

local bodyData = require(script.Parent.Library.BodyData)
local armourInterface = require(script.Parent.Library.ArmourInterface)
local armourPart = require(script.Parent.Library.ArmourPart)

local isClient = game:GetService("RunService"):IsClient()

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local RegularArmour = {}
RegularArmour.__index = RegularArmour

function RegularArmour.new(config,guidObject)
	local self = setmetatable({}, RegularArmour)

	self.Config = config
	
	self.Level = 1

	self.Character = nil
	self.Humanoid = nil
	self.HealthChanged = nil

	self.ArmourParts = {}

	self.Equipped = false
	self.EquipTask = nil

	self.GUIDObject = guidObject
	
	self.ArmourInterface = armourInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function(destroyedGUIDObject)
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function RegularArmour:Init(character,instantEquip)	
	if self.Humanoid then
		self.Humanoid.MaxHealth = 100
		self.Humanoid.Health = 100
	end
	
	self.Character = character
	self.Humanoid = self.Character:FindFirstChild("Humanoid")
	self.GUIDObject.Parent = self.Character

	local maxHealth = self:Interface("GetHealth")
	self.Humanoid.MaxHealth = maxHealth
	self.Humanoid.Health = maxHealth	

	if not isClient then return end
	self:Equip(instantEquip)

	self.HealthChanged = self.HealthChanged and self.HealthChanged:Disconnect()

	self.HealthChanged = self.Humanoid and self.Humanoid.HealthChanged:Connect(function(currentHealth)
		self:OnHealthChange(currentHealth,self.Humanoid.MaxHealth)
	end)
end

function RegularArmour:TriggerArmour()
	if not self.Equipped then
		self:Equip()
	else
		self:Unequip()
	end
end

function RegularArmour:Equip(instantEquip)
	local maxHealth = self:Interface("GetHealth")
	self.Humanoid.MaxHealth = maxHealth
	self.Humanoid.Health = maxHealth	
	
	if not isClient then return end
	
	self.Equipped = true

	self:Unequip(true)

	self.EquipTask = task.spawn(function()
		for _, bodyPartName in ipairs(bodyData.BodyParts) do
			local bodyPart = self.Character[bodyPartName]
			self.ArmourParts[bodyPartName] = self.ArmourParts[bodyPartName] or armourPart.new(self.Config.Armour)
			self.ArmourParts[bodyPartName]:Init(bodyPart,instantEquip)
			if not instantEquip then
				task.wait(0.15)
			end
		end
		self.EquipTask = nil
	end)
end

function RegularArmour:Unequip(skip:boolean?)
	if not isClient then return end

	if self.EquipTask then 
		task.cancel(self.EquipTask)
		self.EquipTask = nil
	end
	
	if not skip then
		for _, bodyPartName in ipairs(bodyData.BodyParts) do
			self.ArmourParts[bodyPartName]:Equip(false)
		end
	end
	
	self.Equipped = false
end

function RegularArmour:OnHealthChange(currentHealth,maxHealth)
	if not isClient then return end
	
	for _, armourPartModule in pairs(self.ArmourParts) do
		armourPartModule:OnHealthChange(currentHealth,maxHealth,true)
	end
end

function RegularArmour:Interface(functionName,...)
	if self._destroyed then return end
	return self.ArmourInterface and self.ArmourInterface:Call(functionName,...)
end

function RegularArmour:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	
	self:Unequip()
	for key, armourPart in pairs(self.ArmourParts) do
		armourPart:Destroy()
		self.ArmourParts[key] = nil
	end
	
	toolsModule.DestroyTool(self.GUIDObject)
end

return RegularArmour