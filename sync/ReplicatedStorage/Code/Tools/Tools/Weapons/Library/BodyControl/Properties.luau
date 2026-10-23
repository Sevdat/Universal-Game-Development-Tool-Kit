local module = {}

function module.AlignOrientationOne(primaryPart)
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Enabled = false
	alignOrientation.MaxTorque = math.huge
	alignOrientation.Responsiveness = 20
	alignOrientation.RigidityEnabled = false
	alignOrientation.Attachment0 = primaryPart.RootRigAttachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.PrimaryAxisOnly = true
	alignOrientation.PrimaryAxis = Vector3.zAxis
	alignOrientation.Parent = primaryPart
	return alignOrientation
end

return module
