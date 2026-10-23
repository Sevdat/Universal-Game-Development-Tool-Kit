local rarityColor = require(script.RarityColor)

local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local Billboard = {}
Billboard.__index = Billboard

function Billboard.new()
	local self = setmetatable({}, Billboard)

	self.Billboard = nil
	self.Progress = nil
	self.Basebar = nil
	self.Bar = nil

	return self
end

function Billboard:Init(billboard)
	self.Billboard = billboard
	
	self.Progress = self.Billboard:FindFirstChild("Progress")
	self.Basebar = self.Billboard:FindFirstChild("BaseBar")
	self.Bar = self.Basebar:FindFirstChild("Bar")

	if not isClient then
		self:Enabled(false)
	end
end

function Billboard:UpdateText(progress)
	self.Progress.Text = "Progress: %" .. string.format("%.1f", progress * 100)
	self.Bar.Size = UDim2.new(progress,0,1,0)
end

function Billboard:Enabled(enabled)
	self.Billboard.Enabled = enabled
end

function Billboard:Destroy()

	table.clear(self)
	setmetatable(self, nil)
end

return Billboard