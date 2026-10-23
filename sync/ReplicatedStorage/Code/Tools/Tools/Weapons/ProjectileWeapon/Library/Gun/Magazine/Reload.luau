local players = game:GetService("Players")
local isClient = game:GetService("RunService"):IsClient()

local externalLibrary = script.Parent.Parent.Parent.Parent.Parent.Library
local spatialSounds = require(externalLibrary.SpatialSounds)

local Reload = {}
Reload.__index = Reload

function Reload.new()
	local self = setmetatable({}, Reload)

	self.Data = nil

	self.Player = nil
	self.Character = nil
	self.Animator = nil
	
	self.IsReloading = nil
	self.ReloadTime = nil
	self.ReloadSound = nil
	self.ReloadAnimation = nil
	self.ReloadAnimationTrack = nil
	
	self.IsIdle = nil
	self.IdleAnimation = nil
	self.IdleAnimationTrack = nil
	self.IdleStoppedConnection = nil

	return self
end

function Reload:Init(character,weaponTables)
	if not isClient then return end
	
	self.Player = players:GetPlayerFromCharacter(character)
	self.Character = character

	self.Animator = isClient and self.Character and self.Character:FindFirstChild("Humanoid"):FindFirstChild("Animator") or nil

	self.BodyPart = self.Character and self.Character.PrimaryPart

	self.WeaponTables = weaponTables
	self.ReloadTime = self.WeaponTables:GetVariable("ReloadTime")
	self.ReloadSound = self.ReloadSound or self.WeaponTables:GetVariable("ReloadSound"):Clone()
	self.ReloadAnimation = self.WeaponTables:GetVariable("ReloadAnimation")
	self.IdleAnimation = self.WeaponTables:GetVariable("IdleAnimation")
	
	self.ReloadSound.Parent = self.BodyPart
	
	self.ReloadCountdown = self.ReloadTime

	if self.Animator then 
		self.IdleAnimationTrack = self.IdleAnimationTrack and self.IdleAnimationTrack:Destroy() or self.Animator:LoadAnimation(self.IdleAnimation)
		self.ReloadAnimationTrack = self.ReloadAnimationTrack and self.ReloadAnimationTrack:Destroy() or self.Animator:LoadAnimation(self.ReloadAnimation)
	end
	
	self:TriggerEquip(true)
end

function Reload:TriggerReload(isReloading)
	self.IsReloading = isReloading
end

function Reload:TriggerEquip(equip:boolean)
	self.IsIdle = equip
	self.IsReloading = false
end

function Reload:Loop(dt)
	if self.ReloadAnimationTrack then
		if self.IsReloading then
			if not self.ReloadAnimationTrack.IsPlaying then
				self.ReloadAnimationTrack:Play()
				self.ReloadSound:Play()
			elseif self.ReloadCountdown > 0 then
				self.ReloadCountdown -= dt
			else
				self.IsReloading = false
			end
		elseif self.ReloadAnimationTrack.IsPlaying then
			self.IsReloading = false
			self.ReloadAnimationTrack:Stop()
			self.ReloadSound:Stop()
			self.ReloadCountdown = self.ReloadTime
			self.IsIdle = true
		end
	end

	if self.IdleAnimationTrack then
		if self.IsIdle then
			if not self.IdleAnimationTrack.IsPlaying then
				self.IdleAnimationTrack:Play()
			end
		else
			if self.IdleAnimationTrack.IsPlaying then
				self.IdleAnimationTrack:Stop()
			end
		end
	end
end

function Reload:Destroy()
	self:TriggerEquip(false)
	
	self.ReloadSound = self.ReloadSound and self.ReloadSound:Destroy()
	self.ReloadAnimationTrack = self.ReloadAnimationTrack and self.ReloadAnimationTrack:Destroy()
	self.IdleAnimationTrack = self.IdleAnimationTrack and self.IdleAnimationTrack:Destroy()
	table.clear(self)
end

return Reload