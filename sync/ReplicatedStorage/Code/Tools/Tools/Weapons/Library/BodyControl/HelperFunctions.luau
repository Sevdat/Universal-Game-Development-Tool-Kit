local module = {}

function module.CreateIK(name,startPart,endPart,parentPart,ikControlType)
	local IKControl = Instance.new("IKControl")
	IKControl.Name = name -- "RightArmIK"
	IKControl.Type = ikControlType

	IKControl.ChainRoot = startPart

	IKControl.EndEffector = endPart
	
	IKControl.SmoothTime = 0

	-- Let the animation and IK blend together
	IKControl.Weight = 0

	IKControl.Parent = parentPart
	
	return IKControl
end

return module
