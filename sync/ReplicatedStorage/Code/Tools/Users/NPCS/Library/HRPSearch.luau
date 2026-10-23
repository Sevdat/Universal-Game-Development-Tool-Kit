local module = {}

local radius = 500

function module.GetHRPInArea(hitbox,humanoidRootParts:{})
	if not next(humanoidRootParts) then return nil end

	local closestPart = nil
	local shortestDistance = math.huge
	
	for _, part in pairs(humanoidRootParts) do		
		local distance = (hitbox.Position - part.Position).Magnitude

		if distance < radius and distance < shortestDistance then
			shortestDistance = distance
			closestPart = part
		end
	end

	return closestPart
end

return module
