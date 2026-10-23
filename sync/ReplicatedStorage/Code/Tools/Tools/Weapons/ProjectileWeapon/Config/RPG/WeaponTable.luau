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
	
	self.FireSound = self.FireSound or self.Data.FireSound:Clone()
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
		
		local fireEmit = cloneProjectile:FindFirstChild("FireEmit")
		local smokeEmit = cloneProjectile:FindFirstChild("SmokeEmit")
		if fireEmit and smokeEmit then
			fireEmit.Enabled = true
			smokeEmit.Enabled = true
		end
		
		local swoosh = cloneProjectile and cloneProjectile:FindFirstChild("Swoosh")
		if swoosh then
			swoosh:Play()
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
	if isClient and projectile and result then
		local hitEffect = self.WeaponConfig.HitEffect:Clone()
		local explosion = Instance.new("Explosion",hitEffect)

		explosion.BlastRadius = 10
		explosion.BlastPressure = 0
		explosion.DestroyJointRadiusPercent = 0
		explosion.ExplosionType = Enum.ExplosionType.NoCraters

		explosion.Position = result.Position
		explosion.Parent = workspace

		hitEffect.CFrame = CFrame.lookAt(
			result.Position + result.Normal * 0.01,
			result.Position + result.Normal
		)

		for _, child in ipairs(projectile:GetChildren()) do
			if child:IsA("ParticleEmitter") then
				child.Parent = workspace
				debris:AddItem(hitEffect, 3)
			end
		end
		
		hitEffect.Parent = workspace
		debris:AddItem(hitEffect, 10)
	end
end

function WeaponTable:OnPositionChange(position, lastPosition,maxFlyDistance)
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