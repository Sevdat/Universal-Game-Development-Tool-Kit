local module = {}

local tweenService = game:GetService("TweenService")

function module.TweenCollectButton(collectPart,particleEmitter)
	particleEmitter.Enabled = true
	local goal = {
		CFrame = collectPart.CFrame + Vector3.new(0, -0.15, 0),
		Color = Color3.fromRGB(255,255,255)
	}

	local tweenInfo = TweenInfo.new(
		0.3,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		0, true, 0
	)

	local tween = tweenService:Create(collectPart, tweenInfo, goal)

	local finished = false

	tween.Completed:Connect(function()
		finished = true
		particleEmitter.Enabled = false
	end)

	tween:Play()

	return function()
		return finished
	end
end

function module.TweenUpgradeButton(upgradePart)
	local size = upgradePart.Size
	local goal = { Size = size*1.2 }

	local tweenInfo = TweenInfo.new(
		0.1,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut,
		0, true, 0
	)

	local tween = tweenService:Create(upgradePart, tweenInfo, goal)
	tween:Play()

	return function()
		if tween.PlaybackState ~= Enum.PlaybackState.Completed then
			tween:Cancel()
		end
		upgradePart.Size = size
	end
end

return module
