local module = {}

local isClient = game:GetService("RunService"):IsClient()

local hrpParams = OverlapParams.new()
hrpParams.FilterType = Enum.RaycastFilterType.Include
hrpParams.FilterDescendantsInstances = {workspace.AllPlayers}
hrpParams.CollisionGroup = "Player"

function module.GetHRPInArea(position,cFrame,size)	
	local parts = workspace:GetPartBoundsInBox(cFrame, size, hrpParams)

	if #parts == 0 then return nil end
	
	return parts
end

return module
