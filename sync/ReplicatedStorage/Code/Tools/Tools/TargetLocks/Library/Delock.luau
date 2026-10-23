local module = {}

local camera = workspace.Camera

local dislockDistance = 300
local dislockAngle = math.rad(40)

function module.CanDelock(target)
	if not target then return end

	local camCFrame = camera.CFrame
	local toTarget = target.Position - camCFrame.Position

	return toTarget.Magnitude > dislockDistance
		or math.acos(camCFrame.LookVector:Dot(toTarget.Unit)) > dislockAngle
end

function module.CanLock(target)
	return not module.CanDelock(target)
end

return module
