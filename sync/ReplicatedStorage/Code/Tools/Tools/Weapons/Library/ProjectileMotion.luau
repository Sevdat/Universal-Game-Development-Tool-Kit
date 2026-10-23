local module = {}

module.Linear = require(script.Linear)
module.Follow = require(script.Follow)

function module.GetProjectileMotion(motionType)
	if motionType == "Linear" then
		return function(weaponTable,position:Vector3,target:Part)
			if position then
				module.Linear.Shoot(weaponTable,position)
			end
		end
	end

	if motionType == "Follow" then
		return function(weaponTable,position:Vector3,target:Part)
			if target then
				module.Follow.FlyToTarget(weaponTable,target)
			elseif position then
				module.Linear.Shoot(weaponTable,position)
			end
		end
	end
end

return module
