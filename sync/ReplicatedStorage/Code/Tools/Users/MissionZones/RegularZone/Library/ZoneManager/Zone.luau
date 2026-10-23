local billboard = require(script.Billboard)
local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local Zone = {}
Zone.__index = Zone

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function Zone.new()
	local self = setmetatable({}, Zone)

	self.ZonePart = nil
	self.Billboard = nil

	return self
end

function Zone:Init(zonePart)
	self.ZonePart = zonePart
	
	self.Billboard = self.Billboard or billboard.new()
	self.Billboard:Init(self.ZonePart:FindFirstChild("Billboard"))
	
	if not isClient then
		self.ZonePart.Transparency = 1
	end
end

function Zone:UpdateColor(color)
	self.ZonePart.Color = color
	self.Billboard:UpdateColor(color)
end

function Zone:UpdateCountdown(timeLeft)
	self.Billboard:UpdateText(timeLeft)
end

function Zone:Enabled(enabled)
	self.Billboard:Enabled(enabled)
	self.ZonePart.Transparency = enabled and 0.75 or 1
end

function Zone:Destroy()


	table.clear(self)
end


return Zone