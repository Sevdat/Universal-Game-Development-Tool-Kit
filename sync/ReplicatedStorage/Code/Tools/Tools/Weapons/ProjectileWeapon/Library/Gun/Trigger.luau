local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

local isClient = game:GetService("RunService"):IsClient()
local localPlayer = isClient and game.Players.LocalPlayer or nil

local externalLibrary = script.Parent.Parent.Parent.Parent.Library
local projectileMotion = require(externalLibrary.ProjectileMotion)
local spatialSounds = require(externalLibrary.SpatialSounds)
local countDownTime = 3

local Trigger = {}
Trigger.__index = Trigger

function Trigger.new()
	local self = setmetatable({}, Trigger)

	self.Data = nil

	self.Player = nil
	self.Character = nil
	self.Animator = nil

	self.BodyPart = nil
	
	self.WeaponTable = nil
	
	self._destroyed = false

	return self
end

function Trigger:Init(weaponTable,character)
	self.Character = character
	self.Animator = isClient and self.Character and self.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator") or nil
	
	self.WeaponTable = weaponTable
	self.WeaponTable:Init(self.Character)

	if self.Animator then 
		self.AttackAnimationTrack = self.Animator:LoadAnimation(self.WeaponTable:GetVariable("AttackAnimation"))
	end
	
	self.MotionType = self.WeaponTable:GetVariable("MotionType")
	self.ProjectileMotion = projectileMotion.GetProjectileMotion(self.MotionType)
	
	self.IsAttacking = false
	self.ShootCountdown = countDownTime
end

function Trigger:Shoot(position:Vector3,target:BasePart)	
	self.ShootCountdown = countDownTime
	self.IsAttacking = true
	
	if isClient then
		task.delay(self.ClientDelayTime, function()
			self.WeaponTable:OnShoot()
			self.ProjectileMotion(self.WeaponTable, position,target)
		end)
		if self.AttackAnimationTrack then
			self.AttackAnimationTrack:Play() 
		end
	else
		task.delay(self.ServerDelayTime, function()
			self.ProjectileMotion(self.WeaponTable, position,target)
		end)
	end
	
	return true
end

function Trigger:Reload()
	if isClient and self.AttackAnimationTrack then
		self.AttackAnimationTrack:Stop()
	end
end

function Trigger:Equip(equip:boolean)
	self.WeaponTable:Equip(equip)
	if isClient and self.AttackAnimationTrack then
		self.AttackAnimationTrack:Stop()
	end
end

function Trigger:StreamEffect(isShooting:boolean)
	self.WeaponTable:StreamEffect(isShooting)
end

function Trigger:AimEffect(from,to)
	self.WeaponTable:AimEffect(from,to)
end

function Trigger:Destroy()
	self._destroyed = true

	self.Start = self.Start and self.Start:Destroy()
	self.Projectile = self.Projectile and self.Projectile:Destroy()

	self.AttackAnimationTrack = self.AttackAnimationTrack and self.AttackAnimationTrack:Destroy()
end

return Trigger