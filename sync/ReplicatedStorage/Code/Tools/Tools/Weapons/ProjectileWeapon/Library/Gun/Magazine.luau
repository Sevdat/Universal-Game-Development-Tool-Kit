local players = game:GetService("Players")
local isClient = game:GetService("RunService"):IsClient()

local reload = require(script.Reload)
local weaponBillboard = require(script.WeaponBillboard)


local Magazine = {}
Magazine.__index = Magazine

function Magazine.new()
	local self = setmetatable({}, Magazine)

	self.Player = nil
	self.Character = nil

	self.FireRate = nil
	self.ReloadTime = nil
	self.NextShotTime = nil
	
	self.MaxAmmo = nil
	self.CurrentAmmo = nil
	
	self.ReloadModule = nil
	
	self.WeaponBillboard = nil

	return self
end

function Magazine:Init(character,weaponTables)
	self.Player = players:GetPlayerFromCharacter(character)
	self.Character = character
	
	self.FireRate = weaponTables:GetVariable("FireRate")
	self.ReloadTime = weaponTables:GetVariable("ReloadTime")
	
	self.NextShotTime = 0
	
	self.WeaponBillboard = self.WeaponBillboard or weaponBillboard.new()
	self.WeaponBillboard:Init(self.Player,self.Character)
	
	self.MaxAmmo = weaponTables:GetVariable("MaxAmmo")
	self.CurrentAmmo = self.MaxAmmo
	
	self.ReloadModule = self.ReloadModule or reload.new()
	self.ReloadModule:Init(character,weaponTables)
end

function Magazine:Shoot()
	local currentTime = workspace:GetServerTimeNow()
	local shot = false

	if currentTime > self.NextShotTime then
		self.NextShotTime = currentTime + (self.CurrentAmmo > 0 and self.FireRate or self.ReloadTime)
		self.CurrentAmmo = math.clamp(self.CurrentAmmo-1,0,self.MaxAmmo) 
		
		self.ReloadModule:TriggerReload(false)
		self.WeaponBillboard:UpdateAmmo(self.CurrentAmmo,self.MaxAmmo)
		shot = true
	end
	
	return shot,self.CurrentAmmo,self.MaxAmmo
end

function Magazine:Equip(equip)
	self.ReloadModule:TriggerEquip(equip)
	self.WeaponBillboard:Visible(equip)
	if not equip and self.CurrentAmmo ~= self.MaxAmmo then
		self.NextShotTime = workspace:GetServerTimeNow() + self.ReloadTime
		self.CurrentAmmo = self.MaxAmmo
		self.WeaponBillboard:Reloading(self.ReloadTime)
	end
end

function Magazine:Reload()
	self.NextShotTime = workspace:GetServerTimeNow() + self.ReloadTime
	self.CurrentAmmo = self.MaxAmmo
	self.WeaponBillboard:Reloading(self.ReloadTime)
	self.ReloadModule:TriggerReload(true)
end

function Magazine:Loop(dt)
	self.ReloadModule:Loop(dt)
end

function Magazine:Destroy()
	self.ReloadModule = self.ReloadModule and self.ReloadModule:Destroy()
	self.WeaponBillboard = self.WeaponBillboard and self.WeaponBillboard:Destroy()
	
	table.clear(self)
end

return Magazine