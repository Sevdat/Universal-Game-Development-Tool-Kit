local players = game:GetService("Players")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local userInputService = game:GetService("UserInputService")

local flightInterface = require(script.Parent.Library.FlightsInterface)
local properties = require(script.Parent.Library.Properties)
local rawInput = require(script.Parent.Library.RawInput)

local isClient = game:GetService("RunService"):IsClient()
local localPlayer = isClient and players.LocalPlayer

local movementInterval = 0.3

local DEADZONE = 0.2

local Regular = {}
Regular.__index = Regular

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function Regular.new(config,guidObject)
	local self = setmetatable({}, Regular)

	self.Config = config

	self.GravityVector = nil
	self.TiltForward = nil

	self.FlyIdle = nil
	self.FlyLeft = nil
	self.FlyRight = nil
	self.FlyForward = nil
	self.FlyBackward = nil

	self.Player = nil
	self.Character = nil
	self.PrimaryPart = nil
	self.Humanoid = nil
	self.Animator = nil
	self.AlignOrientation = nil
	self.VectorForce = nil

	self.Camera = workspace.CurrentCamera
	self.IsFlying = false
	self.IsBoosting = false
	self.LiftOff = 1

	self.CameraTurn = 0
	self.yAxis = 0
	self.xAxis = 0

	self.Particles = nil

	self.LoopFunction = nil

	self.GUIDObject = guidObject
	
	self.FlightInterface = flightInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function Regular:Init(character)
	self.Player = players:GetPlayerFromCharacter(character)
	self.Character = self.Player.Character
	self.Humanoid = self.Character.Humanoid
	
	if isClient then 
		self.PrimaryPart = self.Character.PrimaryPart
		self.Animator = self.Humanoid.Animator
		
		self.TiltForward = CFrame.fromOrientation(0,0,0)
		self.GravityVector = Vector3.new(0,game.Workspace.Gravity,0)

		self.AlignOrientation = properties.AlignOrientationOne(self.PrimaryPart)
		self.VectorForce = properties.VectorForce(self.PrimaryPart)

		self.FlyIdle = self.Animator:LoadAnimation(self.Config.FlyIdle)
		self.FlyIdle.Looped = true

		self.FlyLeft = self.Animator:LoadAnimation(self.Config.FlyLeft)
		self.FlyLeft.Looped = true

		self.FlyRight = self.Animator:LoadAnimation(self.Config.FlyRight)
		self.FlyRight.Looped = true

		self.FlyForward = self.Animator:LoadAnimation(self.Config.FlyForward)
		self.FlyForward.Looped = true

		self.FlyBackward = self.Animator:LoadAnimation(self.Config.FlyBackward)
		self.FlyBackward.Looped = true

		self.Particles = self.Config:InitParticles(self.Character)
		
		self.LoopFunction = self.LoopFunction or function(dt)
			if self._destroyed then return end

			self:FlightPhysics(dt)
			self:Movement(dt)
		end
	else
		for _, part in ipairs(self.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part:SetNetworkOwner(self.Player)
				
			end
		end
	end
	
	self.GUIDObject.Parent = self.Character
end

function Regular:TriggerFlight(on)
	self.IsFlying = on
	self.Humanoid.AutoRotate = not on
	
	if not isClient then return end

	if self.IsFlying then
		
		if self.Player == localPlayer then
			local mass = self.PrimaryPart.AssemblyMass
			if self.Humanoid.FloorMaterial ~= Enum.Material.Air then
				self.LiftOff = 3
			end

			self.VectorForce.Force = self.GravityVector * mass
			self.VectorForce.Enabled = true
			self.AlignOrientation.CFrame = self.PrimaryPart.CFrame
			self.AlignOrientation.Enabled = true
			self.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			
			toolsModule.AddToLoop("Heartbeat",self.LoopFunction)
			
			self:FlightAnimationsController(0,0)

			self:MouseLock(true)
		end
		
		self.Particles:Activate(true)
	else
		if self.Player == localPlayer then
			self.VectorForce.Enabled = false
			self.AlignOrientation.Enabled = false
			self.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			
			self:FlightAnimationsController(nil,nil)

			toolsModule.RemoveFromLoop("Heartbeat",self.LoopFunction)

			self:MouseLock(false)
		end
		
		self.Particles:Activate(false)
	end
end

function Regular:FlightAnimationsController(x,y)
	if not x or not y then
		self.FlyRight:Stop()
		self.FlyLeft:Stop()
		self.FlyForward:Stop()
		self.FlyBackward:Stop()
		self.FlyIdle:Stop()
		return
	end

	local isIdle = true

	if x > DEADZONE then
		if not self.FlyRight.IsPlaying then
			self.FlyRight:Play()
		end
		isIdle = false
	elseif self.FlyRight.IsPlaying then
		self.FlyRight:Stop()
	end

	if x < -DEADZONE then
		if not self.FlyLeft.IsPlaying then
			self.FlyLeft:Play()
		end
		isIdle = false
	elseif self.FlyLeft.IsPlaying then
		self.FlyLeft:Stop()
	end

	if y > DEADZONE then
		if not self.FlyForward.IsPlaying then
			self.FlyForward:Play()
		end
		isIdle = false
	elseif self.FlyForward.IsPlaying then
		self.FlyForward:Stop()
	end

	if y < -DEADZONE then
		if not self.FlyBackward.IsPlaying then
			self.FlyBackward:Play()
		end
		isIdle = false
	elseif self.FlyBackward.IsPlaying then
		self.FlyBackward:Stop()
	end

	if isIdle then
		if not self.FlyIdle.IsPlaying then
			self.FlyIdle:Play()
		end
	elseif self.FlyIdle.IsPlaying then
		self.FlyIdle:Stop()
	end
end

function Regular:FlightPhysics(dt)
	self.GravityVector = Vector3.new(0,game.Workspace.Gravity,0)
	local flightForce = self.Config.FlightForce
	if self.yAxis ~= 1 then
		if self.yAxis == -1 then flightForce = 100 end
		if self.xAxis ~= 0 then flightForce = 100 end
	end
	if self.UsingBoost and self.Boost.Value > 0 then flightForce += self.BoostForce end
	local mass = self.PrimaryPart.AssemblyMass
	local moveVector = self.Humanoid.MoveDirection
	local linearVelocity = self.PrimaryPart.AssemblyLinearVelocity
	local camLook = self.Camera.CFrame.LookVector

	camLook = Vector3.new(camLook.X, (math.abs(self.yAxis)>0 and 1 or 0)*camLook.Y, camLook.Z)

	local baselineForce = self.GravityVector * mass * self.LiftOff
	local vectorForce = baselineForce
	if self.LiftOff > 1 then self.LiftOff = math.clamp(self.LiftOff-0.15,1,3) end

	local directionForce = Vector3.zero
	if moveVector.Magnitude > 0 then
		if math.abs(self.yAxis) > DEADZONE then
			moveVector = camLook*self.yAxis
		else
			moveVector = Vector3.new(moveVector.X,camLook.Y,moveVector.Z)
		end
		directionForce = moveVector*flightForce*mass
		vectorForce += directionForce
	end

	local physicsAlpha = math.clamp(dt * 12 , 0, 1)
	local targetDirection = CFrame.lookAt(Vector3.zero, camLook)
	self.CurrentLookCFrame = (self.CurrentLookCFrame or targetDirection):Lerp(targetDirection, physicsAlpha)
	self.AlignOrientation.CFrame = self.CurrentLookCFrame * self.TiltForward

	if linearVelocity.Magnitude > 0.05 then
		local speed = linearVelocity.Magnitude
		local rawDragForce = speed ^ 1.2 * self.Config.Drag * mass

		local appliedForce = baselineForce + directionForce
		local maxDragForce = appliedForce.Magnitude

		local maxStoppingForce = (mass * speed) / dt

		local dragForce = math.clamp(rawDragForce, 0, math.min(maxDragForce, maxStoppingForce))

		local dragVector = -linearVelocity.Unit * dragForce
		vectorForce += dragVector
	end

	self.VectorForce.Force = vectorForce
end

function Regular:Movement(dt)
	local rawInputVector = rawInput.GetLocalPlayerMoveVector(self.Player)
	self.xAxis = math.round(rawInputVector.X)
	self.yAxis = math.round(rawInputVector.Y)
	
	local deltaTurn = rawInput.GetCameraDelta() * 10
	local decay = math.sign(self.CameraTurn) * dt * 10
	self.CameraTurn = math.abs(decay) >= math.abs(self.CameraTurn) and deltaTurn 
					  or math.clamp(self.CameraTurn - decay+deltaTurn, -math.pi, math.pi)
	
	local targetYaw = (-math.sign(self.xAxis)*2/12) 
	local targetRoll = self.yAxis > 0 and (-self.CameraTurn/4)*math.sign(math.abs(self.yAxis)) or 0
	local targetPitch = self.yAxis > 0 and -math.pi / 2 or 0

	local targetTilt = CFrame.fromOrientation(0, targetYaw, 0) 
		* CFrame.fromOrientation(0, 0, targetRoll) 
		* CFrame.fromOrientation(targetPitch, 0, 0)

	local lerpSpeed = 10 
	local alpha = math.clamp(dt * lerpSpeed, 0, 1)

	self.TiltForward = (self.TiltForward or CFrame.new()):Lerp(targetTilt, alpha)

	local x = math.abs(self.CameraTurn)>0.5 and math.sign(self.CameraTurn) or math.round(rawInputVector.X)

	self:FlightAnimationsController(x, self.yAxis)
end

function Regular:MouseLock(activate)
	self.Active = activate
	userInputService.MouseBehavior = activate and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
	userInputService.MouseIconEnabled = not activate
end

function Regular:Interface(functionName,...)
	if self._destroyed then return end
	return self.FlightInterface and self.FlightInterface:Call(functionName,...)
end

function Regular:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	self:TriggerFlight(false)

	self.FlyIdle = self.FlyIdle and self.FlyIdle:Destroy()
	self.FlyLeft = self.FlyLeft and self.FlyLeft:Destroy()
	self.FlyRight = self.FlyRight and self.FlyRight:Destroy()
	self.FlyForward = self.FlyForward and self.FlyForward:Destroy()
	self.FlyBackward = self.FlyBackward and self.FlyBackward:Destroy()

	self.AlignOrientation = self.AlignOrientation and self.AlignOrientation:Destroy()
	self.VectorForce = self.VectorForce and self.VectorForce:Destroy()

	self.Particles = self.Particles and self.Particles:Destroy()
	
	toolsModule.DestroyTool(self.GUIDObject)
end


return Regular