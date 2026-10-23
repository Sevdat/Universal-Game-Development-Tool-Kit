local players = game:GetService("Players")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local userInputService = game:GetService("UserInputService")

local cameraInterface = require(script.Parent.Library.CameraInterface)
local rawInput = require(script.Parent.Library.RawInput)
local helperFunction = require(script.Parent.Library.HelperFunctions)

local isClient = game:GetService("RunService"):IsClient()
local localPlayer = isClient and players.LocalPlayer

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local SmoothCamera = {}
SmoothCamera.__index = SmoothCamera

function SmoothCamera.new(config,guidObject)
	local self = setmetatable({}, SmoothCamera)

	self.Config = config

	self.Player = nil
	self.Character = nil
	self.Humanoid = nil
	self.PrimaryPart = nil
	self.Camera = nil

	self.TargetOffset = nil
	self.CameraOffset = nil
	self.FollowingOffset = nil
	
	self.XTotal,self.XLerping,self.XDelta = nil,nil,nil
	self.YTotal,self.YLerping,self.YDelta = nil,nil,nil
	
	self.DistanceTotal,self.DistanceLerping,self.DistanceDelta = nil,nil,nil
	
	self.OffsetEnabled = true
	self.SmoothingEnabled = false
	self.SpringEnabled = true
	self.DepthViewEnabled = false

	self.PreRenderConnection = nil

	self.GUIDObject = guidObject
	
	self.CameraInterface = cameraInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function SmoothCamera:Init(character)
	self.Player = players:GetPlayerFromCharacter(character)
	self.Character = self.Player.Character
	self.PrimaryPart = self.Character.Head
	self.Humanoid = self.Character.Humanoid
	
	self.GUIDObject.Parent = self.Character
	
	if not isClient or self.Player ~= localPlayer then return end
	
	self:Trigger(false)
	
	self.TargetOffset = Vector3.new(1, 2, 0)

	self.Camera = workspace.Camera
	
	self.LoopFunction = function(dt)
		self:ThirdPersonCamera(dt)
		self:DepthView(dt)
	end

	self:Trigger(true)
end

function SmoothCamera:Trigger(enable)
	runService:UnbindFromRenderStep("AfterCamera")
	if not enable then return end
	
	self.CurrentOffset = Vector3.zero

	local look = self.Camera.CFrame.LookVector
	self.XTotal,self.XLerping,self.XDelta = math.atan2(-look.X, -look.Z),0,0
	self.YTotal,self.YLerping,self.YDelta = math.asin(look.Y),0,0
	
	local currentDistance = (self.PrimaryPart.CFrame.Position - self.Camera.CFrame.Position).Magnitude
	self.DistanceTotal,self.DistanceLerping,self.DistanceDelta = currentDistance,0,0
	
	runService:BindToRenderStep("AfterCamera", Enum.RenderPriority.Camera.Value+1, self.LoopFunction)
end

function SmoothCamera:ThirdPersonCamera(dt)
	local delta = rawInput.GetCameraRotation()
	self.XDelta = math.lerp(self.XDelta,-delta.X,0.5)
	self.XLerping = math.lerp(self.XLerping-self.XDelta,0,0.98)
	self.XTotal = self.XTotal-self.XLerping

	self.YDelta = math.lerp(self.YDelta,-delta.Y,0.5)
	self.YLerping = math.lerp(self.YLerping-self.YDelta,0,0.98)
	self.YTotal = math.clamp(self.YTotal-self.YLerping, math.rad(-80), math.rad(80))

	self.DistanceDelta = math.lerp(self.DistanceDelta,rawInput.GetZoomDelta(),0.5)
	self.DistanceLerping = math.lerp(self.DistanceLerping-self.DistanceDelta,0,0.9)
	self.DistanceTotal = math.clamp(self.DistanceTotal-self.DistanceLerping,0,50)

	local rootPos = self.PrimaryPart.Position
	local offset = self.OffsetEnabled and self.TargetOffset or Vector3.zero

	local cameraCFrame = CFrame.fromOrientation(self.YTotal, self.XTotal, 0)
		* CFrame.new(0, 0, self.DistanceTotal)
		* CFrame.new(offset)

	local smoothTo = self.SmoothingEnabled and cameraCFrame.Position - offset or Vector3.zero

	if self.SpringEnabled then
		self.CurrentOffset, self.OffsetVelocity = helperFunction.Spring(
			self.CurrentOffset,
			self.OffsetVelocity or Vector3.zero,
			smoothTo,
			80,
			2 * math.sqrt(80),
			dt
		)
		
		self.SmoothedRootPos, self.RootVelocity = helperFunction.Spring(
			self.SmoothedRootPos or rootPos,
			self.RootVelocity or Vector3.zero,
			rootPos,
			80,
			2 * math.sqrt(80),
			dt
		)
	else
		self.CurrentOffset = self.CurrentOffset:Lerp(smoothTo, dt)
		self.SmoothedRootPos = rootPos
		self.RootVelocity = Vector3.zero
	end

	self.Camera.CFrame = CFrame.new(self.SmoothedRootPos + self.CurrentOffset) * cameraCFrame
end

function SmoothCamera:DepthView(dt)
	local delta = rawInput.GetMoveVector()
	
	local targetFOV = (self.DepthViewEnabled and delta.Y > 0) and 92 or 68

	if math.abs(self.Camera.FieldOfView-targetFOV)< 2 then return end
	self.Camera.FieldOfView = self.Camera.FieldOfView + (targetFOV - self.Camera.FieldOfView) * dt
end

function SmoothCamera:Interface(functionName,...)
	if self._destroyed then return end
	return self.CameraInterface and self.CameraInterface:Call(functionName,...)
end

function SmoothCamera:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	
	if localPlayer == self.Player then
		self:Trigger(false)
	end
	
	toolsModule.DestroyTool(self.GUIDObject)
end


return SmoothCamera
