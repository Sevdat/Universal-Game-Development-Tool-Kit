local module = {}

local debris = game:GetService("Debris")
local replicatedStorage = game:WaitForChild("ReplicatedStorage")
local damageIndicator = script.DamageIndicator

local TweenService = game:GetService("TweenService")

local suffix = require(script.Suffix)

function module.ShowDamage(cFrame, damage)
	local temp = damageIndicator:Clone()
	local billboardGui = temp.BillboardGui
	local label1 = billboardGui.TextLabel
	local label2 = billboardGui.TextLabel1

	-- Set text and initial state
	label1.Text = suffix.Shorten(damage)
	label2.Text = suffix.Shorten(damage)
	label1.TextTransparency = 1
	label2.TextTransparency = 1

	-- Position the part at the hit location
	temp.CFrame = cFrame
	temp.Parent = workspace.LocalProjectiles

	-- Define the Tween Infos
	local moveInfo = TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local fadeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	-- 1. Create the random "Up and Out" movement
	local targetOffset = Vector3.new(
		math.random(-30, 30) / 10, -- Random left/right (Horizontal)
		math.random(70, 100) / 10, -- Random up (Vertical)
		0
	)

	-- 2. Play the Tweens
	TweenService:Create(billboardGui, moveInfo, {StudsOffset = targetOffset}):Play()
	TweenService:Create(label1, fadeInfo, {TextTransparency = 0}):Play()
	TweenService:Create(label2, fadeInfo, {TextTransparency = 0}):Play()

	-- 3. Sequence the Fade Out and Cleanup
	task.delay(0.65, function()
		if temp and temp.Parent then
			TweenService:Create(label1, fadeInfo, {TextTransparency = 1}):Play()
			TweenService:Create(label2, fadeInfo, {TextTransparency = 1}):Play()
		end
	end)

	-- Remove the object after the animation is finished
	debris:AddItem(temp, 1.5)
end

return module
