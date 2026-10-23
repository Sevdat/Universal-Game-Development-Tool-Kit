local players = game:GetService("Players")
local httpService = game:GetService("HttpService")
local isClient = game:GetService("RunService"):IsClient()
local debris = game:GetService("Debris")

local weaponConfig = require(script.Parent.WeaponConfig)
local spatialSounds = require(script.Parent.Parent.Parent.Parent.Library.SpatialSounds)

local WeaponTable = {}
WeaponTable.__index = WeaponTable

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function WeaponTable.new(bodyPartName)
	local self = setmetatable({}, WeaponTable)

	self.Level = 1
	self.DamageMultiplier = 1

	self.WeaponConfig = weaponConfig
	self.BodyPartName = bodyPartName
	self.Data = self.WeaponConfig.Data[self.BodyPartName]
	
	self.Character = nil
	self.BodyPart = nil
	self.Scale = 1

	self.WeaponModel = isClient and weaponConfig.ClientModel:Clone() or weaponConfig.ServerModel:Clone()
	self.RootPart = self.WeaponModel.PrimaryPart
	self.Weld = self.RootPart:FindFirstChild("WeldConstraint")
	self.Muzzle = self.WeaponModel:FindFirstChild("Muzzle")

	self.FireSound = self.Data.FireSound:Clone()
	self.FireSound.Parent = self.RootPart

	self.Projectile = self.Data.Projectile

	return self
end

function WeaponTable:Init(character:Model)
	self.Character = character
	self.Scale = self.Character and self.Character:GetScale() or self.Scale
	self.WeaponModel:ScaleTo(self.Scale)
	self.BodyPart = self.Character and (self.Character:FindFirstChild(self.BodyPartName) or self.Character.PrimaryPart)
end

function WeaponTable:Equip(equip:boolean)
	if self.RootPart then
		self.WeaponModel.Parent = equip and self.BodyPart or nil
		self.RootPart.CFrame = self.BodyPart and self.BodyPart.CFrame or self.RootPart.CFrame
		self.Weld.Part1 = equip and self.BodyPart or nil
		self.Weld.Enabled = equip
	end
end

function WeaponTable:Shoot():Vector3&Instance
	local cloneProjectile = nil
	local size = self.Projectile.Size*self.Scale

	local shootFrom = self.Muzzle and self.Muzzle.Position or self.RootPart.Position

	if isClient then
		cloneProjectile = self.Projectile:Clone()
		cloneProjectile.Size = size
		cloneProjectile.Position = shootFrom
		
		local tracer = cloneProjectile:FindFirstChild("Tracer")
		if tracer then
			tracer:Emit(1)
		end
	end

	return shootFrom,size,cloneProjectile
end

function WeaponTable:OnShoot()
	spatialSounds.Play3DSound(self.FireSound)
end

function WeaponTable:StreamEffect(isShooting:boolean)
	if not isClient or not self.Fire or not self.FireLight then return end
	self.Fire.Enabled = isShooting
	self.FireLight.Enabled = isShooting
end

function WeaponTable:AimEffect(from,to)

end

function WeaponTable:OnHit(projectile:Part,result:RaycastResult)

end

function WeaponTable:OnPositionChange(position, lastPosition, maxFlyDistance)
	local maxExpansion = 20
	local distance = (position - self.Muzzle.Position).Magnitude

	maxFlyDistance = math.clamp(maxFlyDistance, 0, 100)

	local ratio = math.clamp(distance / maxFlyDistance, 0, 1) ^ 2

	local size = self.Projectile.Size * self.Scale * (1 + ratio * maxExpansion)
	local lookAtCFrame = CFrame.lookAt(lastPosition, position)

	return size, lookAtCFrame
end

function WeaponTable:GetDamage(result:RaycastResult)
	local damage = self.WeaponConfig.Damage
	local damageMultiplier = self.DamageMultiplier

	local distance = math.clamp(
		(result.Position - self.Muzzle.Position).Magnitude / 500,
		0,
		0.75
	)

	damage *= 1 - distance

	return damage
end

function WeaponTable:SetLevel(newValue)
	self.Level = newValue
end

function WeaponTable:SetDamageMultiplier(newValue)
	self.DamageMultiplier = newValue
end

function WeaponTable:GetVariable(variable:string)
	return self[variable] or self.WeaponConfig[variable] or self.Data[variable]
end

function WeaponTable:Destroy()
	self.WeaponModel = self.WeaponModel and self.WeaponModel:Destroy()
	self.Muzzle = nil
	self.RootPart = nil
	self.PointLight = nil
	self.Sparks = nil
end

return WeaponTable