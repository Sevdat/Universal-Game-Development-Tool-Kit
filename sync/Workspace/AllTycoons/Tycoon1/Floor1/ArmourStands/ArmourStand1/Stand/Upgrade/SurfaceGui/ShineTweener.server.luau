local TweenService = game:GetService("TweenService")


local GUI = script.Parent

local button = GUI.TextButton
local shine = button.Shine


local info = TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.In, -1, false)

shine.Position = UDim2.fromScale(-0.5, 0.5)
TweenService:Create(shine, info, {Position = UDim2.fromScale(1.5, 0.5)}):Play()