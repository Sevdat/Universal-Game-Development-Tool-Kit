local module = {}

local TweenService = game:GetService("TweenService")
local openSound = script:FindFirstChild("UI Click Sound")

function module.Button(button, open:boolean)
	local originalSize = button.Size

	local hoverSize = UDim2.new(
		originalSize.X.Scale * 1.1, 0,
		originalSize.Y.Scale * 1.1, 0
	)

	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function tweenSize(size)
		TweenService:Create(button, tweenInfo, {Size = size}):Play()
	end

	button.InputBegan:Connect(function(input)
		tweenSize(hoverSize)
	end)

	button.InputEnded:Connect(function(input)
		tweenSize(originalSize)
	end)
	
	button.Activated:Connect(function()
		openSound:Play()
	end)
	
	return button
end

return module
