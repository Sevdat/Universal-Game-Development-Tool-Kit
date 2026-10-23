local module = {}
module.__index = module

local debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local suffix = require(script.Parent.Suffix)

local collectSound = script:FindFirstChild("ui_start_travel")

function module.new(container: Frame,data:NumberValue)
	local self = setmetatable({}, module)

	self.CollectSound = collectSound:Clone()
	self.CollectSound.Parent = container
	
	self.Pitch = self.CollectSound:FindFirstChild("PitchShiftSoundEffect")
	self.LastTime = os.time()

	self.Container = container
	self.ImageLabel = self.Container:FindFirstChild("ImageLabel")
	self.Amount = self.Container:FindFirstChild("Amount")
	
	self.Template = self.ImageLabel:FindFirstChild("Template")
	self.OriginalSize = container.Size
	self.ExpandedSize = UDim2.fromScale(self.OriginalSize.X.Scale * 1.1, self.OriginalSize.Y.Scale * 1.1)
	
	self.ExpandTween = TweenService:Create(
		self.Container,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
		{Size = self.ExpandedSize}
	)
	
	self.Data = data
	self.LastAmount = self.Data.Value
	
	self.Amount.Text = suffix.Shorten(self.Data.Value)
	
	self.Data.Changed:Connect(function(newAmount)
		local lastAmount = self.LastAmount
		local increment = newAmount - lastAmount
		self.LastAmount = newAmount
		if newAmount>lastAmount then
			self:TweenTowardsParent(lastAmount,increment)
			self.Pitch.Octave = os.time() - self.LastTime > 5 and 1 or self.Pitch.Octave+0.01
			self.LastTime = os.time()
			self.CollectSound:Stop()
			self.CollectSound:Play()
		else
			self.LastAmount = newAmount
			self.Amount.Text = suffix.Shorten(newAmount)
		end
		self:ExpandContainer()
	end)

	return self
end

function module:TweenTowardsParent(lastAmount,increment)
	local clone = self.Template:Clone()
	local textLabel = clone:FindFirstChild("TextLabel")
	textLabel.Text = "+"..suffix.Shorten(increment)
	
	local from = self.Template.Position
	local to = UDim2.fromScale(
		self.Template.Position.X.Scale + math.random(-50, 50) / 100,
		self.Template.Position.Y.Scale + math.random(90, 110) / 100
	)

	clone.Position = from
	clone.Visible = true
	clone.Parent = self.Container

	local moveTween = TweenService:Create(
		clone,
		TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{Position = to}
	)

	clone.Parent = self.ImageLabel

	moveTween:Play()
	
	moveTween.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed then
			clone.Visible = false
		end
	end)
	
	self.Amount.Text = suffix.Shorten(lastAmount + increment)

	debris:AddItem(clone, 1.5)
end

function module:ExpandContainer()
	self.ExpandTween:Cancel()
	self.Container.Size = self.OriginalSize
	self.ExpandTween:Play()
end

return module