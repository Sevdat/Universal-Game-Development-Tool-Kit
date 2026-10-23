local module = {}

local homingCast = require(script.Parent.Library.HomingCast)
local projectileBehaviour = require(script.Parent.Library.ProjectileBehaviour)
local processHit = require(script.Parent.Library.ProcessHit)

function module.FlyToTarget(weaponTable,target:Part)
	if weaponTable ~= nil and weaponTable._destroyed then return end

	local character = weaponTable.Character
	local primaryPart = character.PrimaryPart
	local currentSpeed = primaryPart and primaryPart.AssemblyLinearVelocity.Magnitude or 0

	local from, size, bullet = weaponTable:Shoot()

	local params = projectileBehaviour.CreateBehaviour(character,bullet)

	local distance = math.clamp(weaponTable:GetVariable("Distance")*(weaponTable.Scale or 1),0,1000)
	local speed = weaponTable:GetVariable("Speed")
	local direction = (target.Position-from).Unit
	local velocity = direction*(speed+currentSpeed)
	local acceleration = weaponTable:GetVariable("Acceleration")
	local canPierce = weaponTable:GetVariable("CanPierce") or false

	return homingCast.SpawnProjectile({
		ProjectilePart = bullet,
		Target = target,
		Position = from,
		MaxFlyDistance = distance,
		Velocity = velocity,
		Acceleration = acceleration,
		BlockcastSize = size,
		RaycastFunction = homingCast.RaycastFunctions.Blockcast,
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

--HomingCast.SpawnProjectile({
--	Position = barrel.Position,
--	Velocity = Vector3.new(0,1,0)*100,
--	Acceleration = Vector3.zero,
--	MaxFlyDistance = 1000,
--	Target = workspace.SpawnLocation,
--	ProjectilePart = part,
--	BlockcastSize = Vector3.new(0.01, 0.01, 0.01),
--	RaycastFunction = HomingCast.RaycastFunctions.Blockcast,
--	RaycastParams = raycastParams,
--	OnHit = function(projectile, raycastResult)
--		print(raycastResult.Instance)
--	end,
--	OnDestroy = function(projectile, reason)
--		local part:BasePart? = projectile.ProjectilePart
--		if part then part:Destroy() end
--	end,
--	OnPositionChange = function(projectile, position, lastPosition)
--		projectile.ProjectilePartRotation = CFrame.lookAt(lastPosition, position)
--	end,
--	OnStep = function(dt)

--	end,
--	UserData = function ()
--		print("lol")
--	end,
--})

return module
