local players = game:GetService("Players")
local httpService = game:GetService("HttpService")
local isClient = game:GetService("RunService"):IsClient()
local debris = game:GetService("Debris")

local weaponConfig = require(script.Parent.WeaponConfig)

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
	
	self.FireSound = self.FireSound or self.Data.FireSound:Clone()
	self.FireSound.Parent = self.RootPart
	
	self.EndPoint = self.WeaponModel:FindFirstChild("EndPoint")
	self.StreamEffectEnabled = false

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
	end

	return shootFrom,size,cloneProjectile
end

function WeaponTable:OnShoot()

end

function WeaponTable:StreamEffect(isShooting:boolean)	
	if not self.EndPoint or not self.Muzzle or self.StreamEffectEnabled == isShooting then return end
	
	self.StreamEffectEnabled = isShooting
	
	for _, child in ipairs(self.EndPoint:GetDescendants()) do
		if child:IsA("ParticleEmitter") or child:IsA("Beam") then
			child.Enabled = isShooting
		end
	end
	
	for _, child in ipairs(self.Muzzle:GetDescendants()) do
		if child:IsA("ParticleEmitter") or child:IsA("Beam") then
			child.Enabled = isShooting
		end
	end
	
	self.FireSound:Stop()
	if not isShooting then return end

	self.FireSound:Play()
end

function WeaponTable:AimEffect(position,target)
	if not self.EndPoint or not position then return end
	
	self.EndPoint.Position = self.EndPoint.Position:Lerp(position or self.EndPoint.Position, 0.1)
end

function WeaponTable:OnHit(projectile:Part,result:RaycastResult)

end

function WeaponTable:OnPositionChange(position, lastPosition, maxFlyDistance)
	local size = self.Projectile.Size*self.Scale
	local lookAtCFrame = CFrame.lookAt(lastPosition, position)
	return size, lookAtCFrame
end

function WeaponTable:GetDamage(result:RaycastResult)
	local baseDamage = self.WeaponConfig.Damage
	local damageMultiplier = self.DamageMultiplier

	local damage = baseDamage+(0.5 * damageMultiplier)

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