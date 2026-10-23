local module = {}

local homingCast = require(script.Parent.Library.HomingCast)
local projectileBehaviour = require(script.Parent.Library.ProjectileBehaviour)
local properties = require(script.Parent.Library.Properties)
local spatialSounds = require(script.Parent.Library.SpatialSounds)

local equipSound = script.Parent.Library["Silksong ui tool equip"]

function module.FlyToTarget(armourPartModule,armourPart,target)
	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {(target and target.Parent)}
	
	if not armourPart or not target then return end
	
	local distance = (armourPart.Position-target.Position).Magnitude
	local velocity = 25

	return homingCast.SpawnProjectile({
		ProjectilePart = armourPart,
		Target = target,
		Position = armourPart.Position,
		MaxFlyDistance = math.huge,
		Velocity = Vector3.new(0,1,0)*velocity,
		RaycastParams = params,
		OnPositionChange = function(projectile, position, lastPosition)
			projectile.ProjectilePartRotation = CFrame.lookAt(lastPosition, position)
		end,
		OnStep = function(projectile,dt)
			projectile.Velocity *= 1.005
		end,
		OnHit = function(projectile, raycastResult)

		end,
		OnDestroy = function(projectile, reason)
			if not armourPart or not target then return end
			
			properties.WeldParts(armourPart,target)
			armourPartModule.Equipping= nil
			if target and target.Parent then
				spatialSounds.Play3DSound(equipSound,target)
			end
		end
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
