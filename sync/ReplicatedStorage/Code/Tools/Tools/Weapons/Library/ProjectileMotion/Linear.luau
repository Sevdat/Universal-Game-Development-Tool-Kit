local module = {}

local swiftCast = require(script.Parent.Library.SwiftCast)
local projectileBehaviour = require(script.Parent.Library.ProjectileBehaviour)
local processHit = require(script.Parent.Library.ProcessHit)

function module.Shoot(weaponTable,to:Vector3)
	if weaponTable ~= nil and weaponTable._destroyed then return end
	
	local character = weaponTable.Character
	local primaryPart = character and character.PrimaryPart
	if not primaryPart then return end
	
	local currentSpeed = primaryPart and primaryPart.AssemblyLinearVelocity.Magnitude or 0
	
	local from, size, bullet = weaponTable:Shoot()
	
	local params = projectileBehaviour.CreateBehaviour(character,bullet)
	
	local distance = math.clamp(weaponTable:GetVariable("Distance")*(weaponTable.Scale or 1),0,1000)
	local speed = weaponTable:GetVariable("Speed")
	local direction = (to-from).Unit
	local velocity = direction*(speed+currentSpeed)
	local acceleration = weaponTable:GetVariable("Acceleration")
	local canPierce = weaponTable:GetVariable("CanPierce") or false

	swiftCast.SpawnProjectile({
		ProjectilePart = bullet,
		Position = from,
		MaxFlyDistance = distance,
		Velocity = velocity,
		Acceleration = acceleration,
		BlockcastSize = size,
		RaycastFunction = swiftCast.RaycastFunctions.Blockcast,
		RaycastParams = params,
		CanPierce = function(projectile, raycastResult)
			return canPierce
		end,
		OnPositionChange = function(projectile, position, lastPosition)
			local maxFlyDistance = projectile.MaxFlyDistance
			local projectilePart = projectile.ProjectilePart
			if not projectilePart then return end
			local currentSize, lookAtCFrame = weaponTable:OnPositionChange(position, lastPosition,maxFlyDistance)
			projectile.ProjectilePart.Size = currentSize or projectile.ProjectilePart.Size
			projectile.ProjectilePartRotation = lookAtCFrame or projectile.ProjectilePartRotation
			projectile.BlockcastSize = currentSize or projectile.BlockcastSize
		end,
		OnStep = function(dt)
			
		end,
		OnHit = function(projectile, raycastResult)
			if not weaponTable or not weaponTable.Character then return end
			weaponTable:OnHit(projectile.ProjectilePart,raycastResult)
			processHit.Result(weaponTable,raycastResult)

			table.insert(projectile.RaycastParams.FilterDescendantsInstances, raycastResult.Instance)
		end,
		OnDestroy = function(projectile, reason)
			local part:BasePart? = projectile.ProjectilePart
			if part then part:Destroy() end
		end,
		UserData = weaponTable
	})
end

return module
