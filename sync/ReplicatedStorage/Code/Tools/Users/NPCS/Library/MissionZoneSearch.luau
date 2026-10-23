local module = {}

local hrpParams = OverlapParams.new()
hrpParams.FilterType = Enum.RaycastFilterType.Include
hrpParams.FilterDescendantsInstances = {workspace.AllMissionZones}

function module.GetMissionZone(hitbox)
	local activationZones = workspace:GetPartsInPart(hitbox, hrpParams)

	for _, activationZone in ipairs(activationZones) do
		if activationZone.Name == "ActivationZone" then
			return activationZone.Parent
		end
	end

	return nil
end

return module