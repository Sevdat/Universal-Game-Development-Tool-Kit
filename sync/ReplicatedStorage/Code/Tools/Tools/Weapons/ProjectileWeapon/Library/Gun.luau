local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

local isClient = game:GetService("RunService"):IsClient()
local localPlayer = isClient and game.Players.LocalPlayer or nil

local magazine = require(script.Magazine)
local trigger = require(script.Trigger)
local aim = require(script.Parent.Parent.Parent.Library.Aim)
local projectileMotion = require(script.Parent.Parent.Parent.Library.ProjectileMotion)

local defaultName = "Default"

local Gun = {}
Gun.__index = Gun

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function Gun.new()
	local self = setmetatable({}, Gun)

	self.Config = nil

	self.Character = nil
	self.UserGUIDObject = nil
	
	self.WeaponTables = nil
	self.Magazine = nil	
	self.Triggers = {}
	
	self.IsShooting = false
	self.IsReloading = false
	self.IsAutomatic = false

	return self
end

function Gun:Init(config,character)
	self.Config = config
	
	self.Character = character
	self.UserGUIDObject = self.Character and toolsModule.GetGUIDObject(self.Character) or nil

	self.WeaponTables = self.WeaponTables or self.Config.GetWeaponTables()
	self.Keys = self.WeaponTables:GetKeys(self.WeaponTables)

	self.Magazine = self.Magazine or magazine.new()
	self.Magazine:Init(self.Character,self.WeaponTables)
	
	self.IsAutomatic = self.WeaponTables:GetVariable("IsAutomatic")
	
	for bodyPartname,weaponTable in pairs(self.WeaponTables:GetWeaponTables()) do
		self.Triggers[bodyPartname] = self.Triggers[bodyPartname] or trigger.new()
		self.Triggers[bodyPartname]:Init(weaponTable,self.Character)
	end
end

function Gun:PullTrigger(isShooting:boolean)
	self.IsShooting = isShooting
end

function Gun:Shoot()
	local shot,ammoLeft,maxAmmo = nil,nil,nil
	
	if self.IsShooting then
		shot,ammoLeft,maxAmmo = self.Magazine:Shoot()
		
		if shot then
			self.IsReloading = false
			
			local position,target = aim.Get(self.UserGUIDObject)
			
			if not position and not target then return end
			
			local index = (ammoLeft % #self.Keys) + 1
			local key = self.Keys[index]
			
			self.Triggers[key]:Shoot(position,target)

			self.IsShooting = self.IsAutomatic and ammoLeft>0 or false
		end
	end
	
	return shot,ammoLeft,maxAmmo
end

function Gun:Reload()
	self.IsShooting = false
	self.IsReloading = true
	for _,triggerModule in pairs(self.Triggers) do
		triggerModule:Reload()
	end
	
	self.Magazine:Reload()
end

function Gun:Equip(equip)	
	for _,triggerModule in pairs(self.Triggers) do
		triggerModule:Equip(equip)
	end
	
	self.Magazine:Equip(equip)
end

function Gun:Loop(dt)
	local shot,ammoLeft, maxAmmo = self:Shoot()
	self.Magazine:Loop(dt)
	
	local position,target =  self.UserGUIDObject and aim.Get(self.UserGUIDObject) or nil, nil
	
	for _,triggerModule in pairs(self.Triggers) do
		triggerModule:StreamEffect(not self.IsReloading and self.IsShooting)
		triggerModule:AimEffect(position,target)
	end
	
	return shot, ammoLeft, maxAmmo
end

function Gun:GetVariable(variableName)
	return self.WeaponTables and self.WeaponTables:GetVariable(variableName)
end

function Gun:SetLevel(newLevel:number)
	self.WeaponTables:SetLevel(newLevel)
end

function Gun:SetDamageMultiplier(newDamageMultiplier:number)
	self.WeaponTables:SetDamageMultiplier(newDamageMultiplier)
end

function Gun:Destroy()
	for _,triggerModule in ipairs(self.Triggers) do
		triggerModule:Destroy()
	end
	
	self.Magazine:Destroy()
	self.WeaponTables = self.WeaponTables and self.WeaponTables:Destroy()
	table.clear(self)
end

return Gun