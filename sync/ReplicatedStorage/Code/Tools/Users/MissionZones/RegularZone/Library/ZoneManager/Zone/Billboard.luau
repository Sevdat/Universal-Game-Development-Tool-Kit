local rarityColor = require(script.RarityColor)

local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local Billboard = {}
Billboard.__index = Billboard

function Billboard.new()
	local self = setmetatable({}, Billboard)

	self.Billboard = nil
	self.Frame = nil
	self.TextLabel = nil
	
	self.Countdown = nil

	return self
end

function Billboard:Init(billboard)
	self.Billboard = billboard
	
	self.Frame = self.Billboard.Frame
	self.TextLabel = self.Frame.TextLabel

	if not isClient then
		self.Billboard.Enabled = false
	end
end

function Billboard:UpdateText(timeLeft)
	if not isClient then return end
	self.TextLabel.Text = timeLeft

	--math.clamp(math.ceil(self.Countdown.Value - workspace:GetServerTimeNow()),0,math.huge)
end

function Billboard:UpdateColor(color)
	self.Frame.BackgroundColor3 = color
end

function Billboard:Enabled(enabled)
	self.Billboard.Enabled = enabled
end

function Billboard:Destroy()

	table.clear(self)
	setmetatable(self, nil)
end

return Billboard