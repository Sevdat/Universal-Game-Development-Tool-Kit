local tweenService = game:GetService("TweenService")

local TweenTargetLock = {}
TweenTargetLock.__index = TweenTargetLock

function TweenTargetLock.new(targetLock,lockingSound,lockedSound)
	local self = setmetatable({}, TweenTargetLock)
	
	self.Billboard = targetLock
	self.Decal = self.Billboard:FindFirstChild("ImageLabel")
	
	self.LockingSound = lockingSound

	self.Finished = false

	return self
end

function TweenTargetLock:Lock()
	if self.Finished or self.LockingSound.IsPlaying then return end
	self.Finished = true
	self.LockingSound:Play()
	self.Billboard.Size = UDim2.new(0,50,0,50)
	self.Decal.Size = UDim2.new(0,50,0,50)
	self.Decal.ImageColor3 = Color3.fromRGB(255, 0, 4)
	self.Decal.ImageTransparency = 0
end

function TweenTargetLock:Reset()
	self.Finished = false
end

function TweenTargetLock:Destroy()
	self.LockingSound:Stop()
	
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

return TweenTargetLock
