local runService = game:GetService("RunService")
local properties = require(script.Properties)

local isServer = runService:IsServer()

local BodyControl = {}
BodyControl.__index = BodyControl

local aim = require(script.Parent.Aim)
local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function BodyControl.new()
	local self = setmetatable({}, BodyControl)

	self.HumanoidRootPart = nil

	self.Model = nil
	self.Neck = nil
	self.RightShoulder = nil
	self.LeftShoulder = nil
	
	self.AlignOrientation = nil
	self.AlignOrientationEnabled = false
	
	self.UserGUIDObject = nil
	
	self.LoopFunction = nil

	return self
end

function BodyControl:Init(model)
	if isServer then return end
	
	self.Model = model
	self.HumanoidRootPart = self.Model and self.Model:FindFirstChild("HumanoidRootPart")
	self.Humanoid = self.Model and self.Model:FindFirstChild("Humanoid")
	
	self.UserGUIDObject = self.Model and toolsModule.GetGUIDObject(self.Model) or nil

	self:Enabled(false)

	self.Neck = self.Model and self.Model:FindFirstChild("Head"):FindFirstChild("Neck")
	self.RightShoulder = self.Model and self.Model:FindFirstChild("RightUpperArm"):FindFirstChild("RightShoulder")
	self.LeftShoulder = self.Model and self.Model:FindFirstChild("LeftUpperArm"):FindFirstChild("LeftShoulder")
	
	self.AlignOrientation = self.AlignOrientation or properties.AlignOrientationOne(self.HumanoidRootPart)
	self.AlignOrientation.Parent = self.HumanoidRootPart
	
	self.LoopFunction = self.LoopFunction or function(dt)
		self:Loop(dt)
	end
end

function BodyControl:Enabled(enable)
	if isServer or not self.LoopFunction or not self.UserGUIDObject then return end
	
	if enable then
		toolsModule.AddToLoop("RenderStepped",self.LoopFunction)
	else
		toolsModule.RemoveFromLoop("RenderStepped",self.LoopFunction)
		if self.Model and self.Neck and self.RightShoulder and self.LeftShoulder then
			self.Neck.Attachment0.CFrame = CFrame.new(self.Neck.Attachment0.CFrame.Position) * CFrame.new()
			self.RightShoulder.Attachment0.CFrame = CFrame.new(self.RightShoulder.Attachment0.CFrame.Position) * CFrame.new()
			self.LeftShoulder.Attachment0.CFrame = CFrame.new(self.LeftShoulder.Attachment0.CFrame.Position) * CFrame.new()
		end
	end
	
	self.AlignOrientationEnabled = enable
	self.AlignOrientation.Enabled = enable
end

function BodyControl:Loop(dt)
	if not self.HumanoidRootPart then return end
	
	local aimPosition,target = aim.Get(self.UserGUIDObject)
	
	local alignPosition = target and target.Position or aimPosition
	if not alignPosition then return end

	local rootCFrame = self.HumanoidRootPart.CFrame

	local aimDirection = (alignPosition - self.HumanoidRootPart.Position).Unit
	local localDirection = rootCFrame:VectorToObjectSpace(aimDirection)

	local pitch = math.asin(localDirection.Y)

	self.Neck.Attachment0.CFrame = self.Neck.Attachment0.CFrame:Lerp(
		CFrame.new(self.Neck.Attachment0.CFrame.Position) * CFrame.Angles(pitch / 2, 0, 0),
		0.1
	)

	self.RightShoulder.Attachment0.CFrame = self.RightShoulder.Attachment0.CFrame:Lerp(
		CFrame.new(self.RightShoulder.Attachment0.CFrame.Position) * CFrame.Angles(pitch, 0, 0),
		0.1
	)

	self.LeftShoulder.Attachment0.CFrame = self.LeftShoulder.Attachment0.CFrame:Lerp(
		CFrame.new(self.LeftShoulder.Attachment0.CFrame.Position) * CFrame.Angles(pitch, 0, 0),
		0.1
	)

	self.AlignOrientation.Enabled = self.AlignOrientationEnabled and self.Humanoid and self.Humanoid:GetState() ~= Enum.HumanoidStateType.Physics
	
	self.AlignOrientation.CFrame = CFrame.lookAt(
		self.HumanoidRootPart.Position,
		Vector3.new(alignPosition.X,self.HumanoidRootPart.Position.Y,alignPosition.Z)
	)
end

function BodyControl:Destroy()
	self:Enabled(false)
	aim.Remove(self.UserGUIDObject)
	table.clear(self)
	
end

return BodyControl

--if count < 0 then return end
--count-=dt
--local x, y, z = self.Camera.CFrame:ToOrientation()

--self.Neck.Attachment0.CFrame =
--	CFrame.new(self.InitialNeckC0) * CFrame.Angles(x, y, z)

--self.Neck.Attachment0.CFrame = self.Neck.Attachment0.CFrame:Lerp(self.InitialNeckC0 * CFrame.Angles(math.asin(cameraDirection.Y),0,0) * CFrame.Angles(0,0,math.asin(cameraDirection.X)),0.5 / 2)
--self.RightShoulder.Attachment0.CFrame = self.RightShoulder.Attachment0.CFrame:Lerp(self.InitialRightShoulderC0 * CFrame.Angles(0,0,-math.asin(cameraDirection.Y)),0.5 / 2)
--self.LeftShoulder.Attachment0.CFrame = self.LeftShoulder.Attachment0.CFrame:Lerp(self.InitialLeftShoulderC0 * CFrame.Angles(0,0,math.asin(cameraDirection.Y)),0.5 / 2)