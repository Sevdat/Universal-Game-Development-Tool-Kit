local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

local isClient = game:GetService("RunService"):IsClient()
local localPlayer = isClient and game.Players.LocalPlayer or nil

local gun = require(script.Library.Gun)
local bodyControl = require(script.Parent.Library.BodyControl)
local weaponInterface = require(script.Parent.Library.WeaponInterface)
local backpackTool = require(script.Parent.Library.BackpackTool)

local ProjectileWeapon = {}
ProjectileWeapon.__index = ProjectileWeapon

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function ProjectileWeapon.new(config,guidObject)
	local self = setmetatable({}, ProjectileWeapon)

	self.Config = config

	self.Player = nil
	self.Character = nil
	
	self.Gun = nil
	self.BodyControl = nil
	self.BackpackTool = nil
	
	self.AmmoLeft = nil
	self.MaxAmmo = nil
	
	self.LoopFunction = nil

	self.GUIDObject = guidObject
	
	self.WeaponInterface = weaponInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function ProjectileWeapon:Init(character)
	self.Player = players:GetPlayerFromCharacter(character)
	self.Character = character
	self.UserGUIDObject = self.Character and toolsModule.GetGUIDObject(self.Character) or nil
	
	self.BodyControl = self.BodyControl or bodyControl.new()
	self.BodyControl:Init(self.Character)
	
	self.Gun = self.Gun or gun.new()
	self.Gun:Init(self.Config,self.Character)

	self.GUIDObject.Parent = self.Character
	
	self.BackpackTool = self.BackpackTool or self.Player and backpackTool.Create(self.Player,self.GUIDObject)
	
	if not isClient and self.BackpackTool then
		self.BackpackTool.Parent = self.Player and self.Player.Backpack
	end
	
	self.LoopFunction = self.LoopFunction or function(dt)
		local shot,ammoLeft,maxAmmo = self.Gun:Loop(dt)
		
		self.AmmoLeft = ammoLeft or self.AmmoLeft
		self.MaxAmmo = maxAmmo or self.MaxAmmo
		
		if not isClient and shot and ammoLeft <= 0 then 
			self:Interface("RequestReload",true,true)
		end
	end
end

function ProjectileWeapon:PullTrigger(triggerPulled:boolean)
	self.Gun:PullTrigger(triggerPulled)
end

function ProjectileWeapon:Reload()
	self.Gun:Reload()
	self.AmmoLeft = self.MaxAmmo
end

function ProjectileWeapon:Equip(enable,blockLoop)
	self.Gun:Equip(enable)
	self.BodyControl:Enabled(enable)
	
	if not blockLoop then
		self.LoopFunction(0)
		
		if enable then
			toolsModule.AddToLoop("Heartbeat",self.LoopFunction)
		else
			toolsModule.RemoveFromLoop("Heartbeat",self.LoopFunction)
		end
	end
end

function ProjectileWeapon:GetVariable(variableName)
	return self.Gun:GetVariable(variableName)
end

function ProjectileWeapon:SetLevel(newLevel:number)
	self.Gun:SetLevel(newLevel)
end

function ProjectileWeapon:Interface(functionName,...)
	if self._destroyed then return end
	return self.WeaponInterface and self.WeaponInterface:Call(functionName,...)
end

function ProjectileWeapon:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	
	self:Equip(false)
	self.Gun = self.Gun and self.Gun:Destroy()
	self.BodyControl = self.BodyControl and self.BodyControl:Destroy()
	
	self.BackpackTool = self.BackpackTool and self.BackpackTool:Destroy()
	
	toolsModule.DestroyTool(self.GUIDObject)
end

return ProjectileWeapon