local module = {}

local hitboxParams = OverlapParams.new()
hitboxParams.FilterType = Enum.RaycastFilterType.Include
hitboxParams.FilterDescendantsInstances = {workspace.AllNPC.ServerModels}

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.AllNPC.ServerModels}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

function module.MovementLogicServer(hitbox:Part, movementArea:Part, targetHRP:Part, speed:number, movementInterval:number)
	if not targetHRP then return end

	local moveDir = Vector3.zero
	local lookAtTarget = Vector3.new(targetHRP.Position.X, hitbox.Position.Y, targetHRP.Position.Z)
	local diff = lookAtTarget - hitbox.Position
	local dist = diff.Magnitude

	if dist > 75 then 
		moveDir = diff.Unit
	elseif dist < 45 then 
		moveDir = -diff.Unit
	end

	local nearbyParts = workspace:GetPartBoundsInBox(hitbox.CFrame, hitbox.Size, hitboxParams)
	for _, part in pairs(nearbyParts) do 
		if part:HasTag("Hitbox") and part ~= hitbox then 
			local diff = (hitbox.Position - part.Position)
			local flatDiff = Vector3.new(diff.X, 0, diff.Z)
			local dist = flatDiff.Magnitude

			if dist < 8 and dist > 0.1 then
				local push = flatDiff.Unit * (1 - (dist / 8))
				moveDir = moveDir + (push * 1.2)
			end
		end
	end

	local nextPos = hitbox.Position

	-- Only calculate nextPos if there is an actual direction to move
	if moveDir.Magnitude > 0 then
		-- Normalize and apply speed
		local normalizedDir = moveDir.Unit
		nextPos = hitbox.Position + (normalizedDir * speed * movementInterval)
	end

	-- Raycast for ground detection
	local rayOrigin = nextPos + Vector3.new(0, 0, 0)
	local rayDirection = Vector3.new(0, -(hitbox.Size.Magnitude), 0)

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	-- Use a fallback Y if the raycast misses, or keep current height
	local calculatedY = raycastResult and raycastResult.Position.Y + (hitbox.Size.Y / 2) or hitbox.Position.Y

	nextPos = Vector3.new(nextPos.X, calculatedY, nextPos.Z)

	local localNextPos = movementArea.CFrame:PointToObjectSpace(nextPos)
	local halfSize = movementArea.Size / 2

	local clampedLocalPos = Vector3.new(
		math.clamp(localNextPos.X, -halfSize.X, halfSize.X),
		localNextPos.Y,
		math.clamp(localNextPos.Z, -halfSize.Z, halfSize.Z)
	)

	local finalPos = movementArea.CFrame:PointToWorldSpace(clampedLocalPos)

	hitbox.CFrame = CFrame.lookAt(finalPos, lookAtTarget)
end

return module
