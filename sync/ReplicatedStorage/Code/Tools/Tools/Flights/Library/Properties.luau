local module = {}

function module.AlignOrientationOne(primaryPart)
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Enabled = false
	alignOrientation.MaxTorque = math.huge
	alignOrientation.Responsiveness = 20
	alignOrientation.RigidityEnabled = false
	alignOrientation.Attachment0 = primaryPart.RootRigAttachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Parent = primaryPart
	return alignOrientation
end

function module.VectorForce(primaryPart)
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Enabled = false
	vectorForce.Force = Vector3.new(0,0,0)
	vectorForce.Attachment0 = primaryPart.RootRigAttachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.Parent = primaryPart
	return vectorForce
end

function module.LinearVelocity(primaryPart)
	local vectorForce = Instance.new("LinearVelocity")
	vectorForce.Enabled = false
	vectorForce.VectorVelocity = Vector3.new(0,0,0)
	vectorForce.Attachment0 = primaryPart.RootRigAttachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Parent = primaryPart
	return vectorForce
end

return module
