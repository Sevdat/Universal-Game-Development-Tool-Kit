local module = {}

local tweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(
	0.4,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0.1
)

function module.Tween(currentHealth,maxHealth,tween,healthAndName)
	if not (healthAndName and healthAndName.Parent) then return end

	if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
		tween:Cancel()
	end

	local healthbar = healthAndName:FindFirstChild("HealthBar")
	local health = healthbar:FindFirstChild("Health")
	local damage = healthbar:FindFirstChild("Damage")

	local newHealthRatio = math.clamp(currentHealth / maxHealth, 0, 1)
	local oldHealthRatio = health.Size.X.Scale

	health.Size = UDim2.new(newHealthRatio, 0, 1, 0)

	local gapWidth = oldHealthRatio - newHealthRatio

	if gapWidth > 0 then
		damage.Position = UDim2.new(newHealthRatio, 0, 0, 0)
		damage.Size = UDim2.new(gapWidth, 0, 1, 0)

		tween = tweenService:Create(damage, tweenInfo, {
			Size = UDim2.new(0, 0, 1, 0)
		})
		tween:Play()
	else
		damage.Size = UDim2.new(0, 0, 1, 0)
	end
	
	return tween
end

return module
