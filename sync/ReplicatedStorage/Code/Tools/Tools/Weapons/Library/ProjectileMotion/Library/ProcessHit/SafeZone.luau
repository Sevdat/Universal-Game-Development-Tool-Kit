local module = {}

local safeZone = workspace:FindFirstChild("SafeZones"):GetChildren()

function module.IsPositionInsidePart(position: Vector3): boolean
	for i,part in ipairs(safeZone) do
		local relative = part.CFrame:PointToObjectSpace(position)
		local halfSize = part.Size * 0.5

		local isInSafeZone = math.abs(relative.X) <= halfSize.X
			and math.abs(relative.Y) <= halfSize.Y
			and math.abs(relative.Z) <= halfSize.Z
		
		if isInSafeZone then
			return true
		end
	end
	
	return false
end

return module
