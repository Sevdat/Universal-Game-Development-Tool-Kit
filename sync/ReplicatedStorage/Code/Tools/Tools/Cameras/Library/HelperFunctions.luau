local module = {}

function module.Spring(position, velocity, target, stiffness, damping, dt)
	local acceleration = (target - position) * stiffness - velocity * damping

	velocity += acceleration * dt
	position += velocity * dt

	return position, velocity
end

return module
