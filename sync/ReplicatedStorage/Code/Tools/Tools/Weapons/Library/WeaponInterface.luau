local WeaponInterface = {}
WeaponInterface.__index = WeaponInterface

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local isStudio = game:GetService("RunService"):IsStudio()
local isClient = game:GetService("RunService"):IsClient()
local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService")

local aim = require(script.Parent.Aim)

local remote = require(script.Parent.Remote)

local activeWeapons = remote.ActiveWeapons
local shootRemote = remote.ShootRemote
local setAimRemote = remote.SetAimRemote
local equipRemote = remote.EquipRemote
local reloadRemote = remote.ReloadRemote
local showDamageRemote = remote.ShowDamageRemote

function WeaponInterface.new(weaponModule)
	local self = setmetatable({}, WeaponInterface)
	self.WeaponModule = weaponModule
	
	return self
end

function WeaponInterface:Call(functionName:string,...)
	if not self.WeaponModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	
	if isStudio then error("No function named: "..functionName) end
end

function WeaponInterface:Init(character)
	self.WeaponModule:Init(character)
end

function WeaponInterface:SetLevel(newLevel)
	self.WeaponModule:SetLevel(newLevel)
end

function WeaponInterface:SetDamageMultiplier(newMultiplier)
	self.WeaponModule.DamageMultiplier = newMultiplier
end

function WeaponInterface:GetVariable(variableName)
	return self.WeaponModule:GetVariable(variableName)
end

function WeaponInterface:RequestSetAim(position:Vector3,target:BasePart,permitShot:boolean?,permitRemote:boolean?)
	local userGUIDObject = self.WeaponModule and self.WeaponModule.UserGUIDObject

	if not userGUIDObject or not aim.CanUpdate(userGUIDObject) then return end
	
	if permitShot then
		aim.Update(userGUIDObject,position,target)
	end

	if permitRemote then 
		if isClient then
			setAimRemote:FireServer(self.WeaponModule.GUIDObject,position,target)
		else
			setAimRemote:FireAllClients(self.WeaponModule.GUIDObject,position,target)
		end
	end
end

function WeaponInterface:RequestShoot(triggerPulled:boolean,permitShot:boolean?,permitRemote:boolean?)
	if permitShot then
		self.WeaponModule:PullTrigger(triggerPulled)
	end

	if not permitRemote then return end

	if isClient then
		shootRemote:FireServer(self.WeaponModule.GUIDObject,triggerPulled)
	else
		shootRemote:FireAllClients(self.WeaponModule.GUIDObject,triggerPulled)
	end
end

function WeaponInterface:RequestReload(permitReload:boolean?,permitRemote:boolean?)
	local gun = self.WeaponModule

	if gun.AmmoLeft ~= gun.MaxAmmo then
		if permitReload then
			self.WeaponModule:Reload()
		end
		
		if not permitRemote then return end
		
		if isClient then
			reloadRemote:FireServer(self.WeaponModule.GUIDObject)
		else
			reloadRemote:FireAllClients(self.WeaponModule.GUIDObject)
		end
	end
end

function WeaponInterface:RequestEquip(visible,permitEquip:boolean?,permitRemote:boolean?)
	if permitEquip then
		self.WeaponModule:Equip(visible)
	end

	if not permitRemote then return end

	if isClient then
		equipRemote:FireServer(self.WeaponModule.GUIDObject,visible)
	else
		equipRemote:FireAllClients(self.WeaponModule.GUIDObject,visible)
	end
end

function WeaponInterface:Destroy()
	self.WeaponModule:Destroy()
end

return WeaponInterface