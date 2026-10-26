--Connected Discord-GitHub

local players = game:GetService("Players") --Access to all current players
local runService = game:GetService("RunService") --Access to loops, execution enviroment, etc
local httpService = game:GetService("HttpService") --Currently unnecesary. Was used to create GUID
local userInputService = game:GetService("UserInputService") --Access to hardware inputs.

local flightInterface = require(script.Parent.Library.FlightsInterface) --External access for this module to be accessed from outside this module safely
local properties = require(script.Parent.Library.Properties) --Quick creation of AlignOrientation and VectorForce
local rawInput = require(script.Parent.Library.RawInput) --Access to IAS inputs

local isClient = game:GetService("RunService"):IsClient() --Get booleon of true if operated in Users hardware
local localPlayer = isClient and players.LocalPlayer --Get the Users player data

local movementInterval = 0.3 --Currently unnecesary. Was used to control how ofter heartbeat loop triggered

local DEADZONE = 0.2 --Is being used to control flight animation from IAS inputs

local Regular = {} --Create Table
Regular.__index = Regular --Looks for methods inside the metatables if missing in the created table

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1] --Link to the very top of the program allowing access to anything required

function Regular.new(config,guidObject) --Create metatable function
	local self = setmetatable({}, Regular) --Sets empty table to metatable

	self.Config = config --Constant variables and functions to be used

	self.GravityVector = nil --For Workspace gravity 
	self.TiltForward = nil --For AlignOrientation bending forward 

	self.FlyIdle = nil --For the pointer of loaded animation 
	self.FlyLeft = nil --For the pointer of loaded animation 
	self.FlyRight = nil --For the pointer of loaded animation 
	self.FlyForward = nil --For the pointer of loaded animation 
	self.FlyBackward = nil --For the pointer of loaded animation 

	self.Player = nil --For the user's player using this module
	self.Character = nil --For the player's character using this module
	self.PrimaryPart = nil --For the character's primarypart
	self.Humanoid = nil --For the character's humanoid
	self.Animator = nil --For the humaoind's animator
	self.AlignOrientation = nil --For the alignOrientation controlling the primaryParts rotation focused on the camera's forward look
	self.VectorForce = nil --For moving the character without disturbing the physics engine's variables

	self.Camera = workspace.CurrentCamera -- Current camera being looked from... I feel like this could be a problem
	self.IsFlying = false --Boolean that identifies if currently is flying
	self.IsBoosting = false --Boolean that identifies if currently is fying faster temperoraly. Future feature.
	self.LiftOff = 1 -- Small boost world up when flight begins

	self.CameraTurn = 0 --For the x rotation of the screen to move the character
	self.yAxis = 0 --For the character movement direction Y
	self.xAxis = 0 --For the character movement direction x

	self.Particles = nil --For enabling particle's effects obtained from the config attached to the character's parts

	self.LoopFunction = nil --The function to add to the global function pair loop where the function's pointer is the key and the element to be accessed at O(1) time

	self.GUIDObject = guidObject --StringValue containing the GUID of the module in the Global Cache
	
	self.FlightInterface = flightInterface.new(self) --The external Interface as an object for this specific metatable.
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function() --Trigger when  StringValue is destroyed
		self:Interface("Destroy") --Destroys the metatable and removes itself from the Global Cache
	end)
	
	self._destroyed = false --Boolean to check if module's destroy function has been triggered so the external interface function won't trigger anymore functions

	return self
end

function Regular:Init(character) --Initilize the module which is reusuble if needed to be attached to a different character
	self.Player = players:GetPlayerFromCharacter(character) --Returns player from the character. 
	self.Character = self.Player.Character --Gets the character from the player object back...unnecesary but is ok
	self.Humanoid = self.Character.Humanoid --Gets the humanoind, but using findfirstchild would be safer because it wouldn't error if humanoid doesn't get found
	
	if isClient then --Trigger's the code block only in client
		self.PrimaryPart = self.Character.PrimaryPart --Returns the PrimaryPart from the character.  Since this is used for players it will be the humanoidRootParts
		self.Animator = self.Humanoid.Animator --Returns the animator inside the humanoid
		
		self.TiltForward = CFrame.fromOrientation(0,0,0) --Don't tilt forward by setting the orientations offset to 0,0,0
		self.GravityVector = Vector3.new(0,game.Workspace.Gravity,0) --Default workspace gravity. 

		self.AlignOrientation = properties.AlignOrientationOne(self.PrimaryPart) --Assign alignorientation and parent it to Primary part
		self.VectorForce = properties.VectorForce(self.PrimaryPart) --Assigns VectorForce and parents to PrimaryPart

		self.FlyIdle = self.Animator:LoadAnimation(self.Config.FlyIdle) --Loads idle animation track
		self.FlyIdle.Looped = true --Sets idle animation to loop, but could have just set it when creating the animation

		self.FlyLeft = self.Animator:LoadAnimation(self.Config.FlyLeft) --Loads left animation track
		self.FlyLeft.Looped = true --Sets idle animation to loop, but could have just set it when creating the animation

		self.FlyRight = self.Animator:LoadAnimation(self.Config.FlyRight)  --Loads right animation track
		self.FlyRight.Looped = true --Sets idle animation to loop, but could have just set it when creating the animation

		self.FlyForward = self.Animator:LoadAnimation(self.Config.FlyForward)  --Loads forward animation track
		self.FlyForward.Looped = true --Sets idle animation to loop, but could have just set it when creating the animation

		self.FlyBackward = self.Animator:LoadAnimation(self.Config.FlyBackward) --Loads backward animation track
		self.FlyBackward.Looped = true --Sets idle animation to loop, but could have just set it when creating the animation

		self.Particles = self.Config:InitParticles(self.Character) --Fuction from config to attach particles to character and trigger enable or destroy
		
		self.LoopFunction = self.LoopFunction or function(dt) 
			if self._destroyed then return end -- block if metatable's function is destroyed

			self:FlightPhysics(dt) --to calculate the vectorforce for flight mechanics and direction
			self:Movement(dt) --movement of animations depending on
		end
	else
		for _, part in ipairs(self.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part:SetNetworkOwner(self.Player) --Set ownership of each part from the server to client so the client can decide it's physics transformations
			end
		end
	end
	
	self.GUIDObject.Parent = self.Character --Parent the StringValue to Character
end

function Regular:TriggerFlight(on) --For triggering flight on or off
	self.IsFlying = on -- Set the booleon of flight
	self.Humanoid.AutoRotate = not on --Disable the humanoids auto rotate so it doesn't mess with alignorientation
	
	if not isClient then return end -- Only continiue the rest of the code for this function on client side

	if self.IsFlying then -- Trigger if currently flight is allowed
		
		if self.Player == localPlayer then -- Allow the flight calculation only for client user's player for performance gain due to each client owning its own part's calculations
			local mass = self.PrimaryPart.AssemblyMass -- Get the mass from the entire character model attached to the primarypart
			if self.Humanoid.FloorMaterial ~= Enum.Material.Air then --Allow codeblock if player is not on air
				self.LiftOff = 3 -- Give lift off boost
			end

			self.VectorForce.Force = self.GravityVector * mass --Counteract the force gravity applies by using the mass of the player times the equal force upwards
			self.VectorForce.Enabled = true --Enable vectorforce
			self.AlignOrientation.CFrame = self.PrimaryPart.CFrame --Set the Cframe of the alignorientation to primary part
			self.AlignOrientation.Enabled = true -- Enable alignorientation
			self.Humanoid:ChangeState(Enum.HumanoidStateType.Physics) -- Change the HumanoidStateType so that fying won't become awkward
			
			toolsModule.AddToLoop("Heartbeat",self.LoopFunction) --Add the LoopFunction to the global loop where a single heartbeat event triggers each function
			
			self:FlightAnimationsController(0,0) --Set flight to idle

			self:MouseLock(true) --Lock mouse to the center of the screen and make it invisable
		end
		
		self.Particles:Activate(true) --Enable the particles visibility
	else --Execute code block if flight is not permitted
		if self.Player == localPlayer then -- trigger on localplayer
			self.VectorForce.Enabled = false -- Disable vectorforce
			self.AlignOrientation.Enabled = false -- disable alignorientation
			self.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall) -- Disable physics humanoidstatetype and set humanoid to free fall to trigger fall animation and default it
			
			self:FlightAnimationsController(nil,nil) -- Disable animations

			toolsModule.RemoveFromLoop("Heartbeat",self.LoopFunction) -- Remove from global loop function

			self:MouseLock(false) -- Reset mouse
		end
		
		self.Particles:Activate(false) -- disable particle effects
	end
end

function Regular:FlightAnimationsController(x,y) -- To trigger animations depending on mouse movements
	if not x or not y then -- Stop all Animations when x or y is set to nil
		self.FlyRight:Stop()
		self.FlyLeft:Stop()
		self.FlyForward:Stop()
		self.FlyBackward:Stop()
		self.FlyIdle:Stop()
		return
	end

	local isIdle = true --If nothing changes this then that means the mouse didn't move

	if x > DEADZONE then -- Trigger Right animations on player movement right x or disable
		if not self.FlyRight.IsPlaying then
			self.FlyRight:Play()
		end
		isIdle = false
	elseif self.FlyRight.IsPlaying then
		self.FlyRight:Stop()
	end

	if x < -DEADZONE then -- Trigger Right animations on player movement left x or disable
		if not self.FlyLeft.IsPlaying then
			self.FlyLeft:Play()
		end
		isIdle = false
	elseif self.FlyLeft.IsPlaying then
		self.FlyLeft:Stop()
	end

	if y > DEADZONE then -- Trigger Forward animations on player movement up y or disable
		if not self.FlyForward.IsPlaying then
			self.FlyForward:Play()
		end
		isIdle = false
	elseif self.FlyForward.IsPlaying then
		self.FlyForward:Stop()
	end

	if y < -DEADZONE then -- Trigger Bacward animations on player movement up y or disable
		if not self.FlyBackward.IsPlaying then
			self.FlyBackward:Play()
		end
		isIdle = false
	elseif self.FlyBackward.IsPlaying then
		self.FlyBackward:Stop()
	end

	if isIdle then --If not of the blocks triggered above then that means the player is idle and idle animations should play or be disabled
		if not self.FlyIdle.IsPlaying then
			self.FlyIdle:Play()
		end
	elseif self.FlyIdle.IsPlaying then
		self.FlyIdle:Stop()
	end
end

function Regular:FlightPhysics(dt) --This is where the flight calculations happen by using the drag equation. 
	self.GravityVector = Vector3.new(0,game.Workspace.Gravity,0) --Gets the current gravity vector applying to the player 
	local flightForce = self.Config.FlightForce --Gets the max force applied to the player from flight
	if self.yAxis ~= 1 then -- Limit flightforce if movement input y is not up
		if self.yAxis == -1 then flightForce = 100 end
		if self.xAxis ~= 0 then flightForce = 100 end
	end
	if self.UsingBoost and self.Boost.Value > 0 then flightForce += self.BoostForce end -- Future feature to make the flight faster temperoraly.
	local mass = self.PrimaryPart.AssemblyMass -- Get the mass of character
	local moveVector = self.Humanoid.MoveDirection -- Get the direction of the humanoids movement
	local linearVelocity = self.PrimaryPart.AssemblyLinearVelocity --Get the current velocity vector3 of primaryPart
	local camLook = self.Camera.CFrame.LookVector

	camLook = Vector3.new(camLook.X, (math.abs(self.yAxis)>0 and 1 or 0)*camLook.Y, camLook.Z) -- Adjusts camera look vector based on forward/backward input to limit the character's motion to x and z plane

	local baselineForce = self.GravityVector * mass * self.LiftOff -- Constant Counteract and liftoff
	local vectorForce = baselineForce -- Duplicate pointer of baselineForce for future manipulation
	if self.LiftOff > 1 then self.LiftOff = math.clamp(self.LiftOff-0.15,1,3) end -- Lerp the liftoffs value

	local directionForce = Vector3.zero --Set the direction the vectorforce will give its force
	if moveVector.Magnitude > 0 then -- Execute code block when character movement is triggered by input
		if math.abs(self.yAxis) > DEADZONE then --Trigger if forward input going towards the camera's direction
			moveVector = camLook*self.yAxis -- Fly towards the direction of the camera either backwards or forwards
		else
			moveVector = Vector3.new(moveVector.X,camLook.Y,moveVector.Z) --Fly towards the right or left depending on character motion
		end
		directionForce = moveVector*flightForce*mass --Apply the the direction the force will go
		vectorForce += directionForce -- Add directionForce to vectorForce
	end

	local physicsAlpha = math.clamp(dt * 12 , 0, 1) -- This chunk is to tile the character forward
	local targetDirection = CFrame.lookAt(Vector3.zero, camLook)
	self.CurrentLookCFrame = (self.CurrentLookCFrame or targetDirection):Lerp(targetDirection, physicsAlpha)
	self.AlignOrientation.CFrame = self.CurrentLookCFrame * self.TiltForward

	if linearVelocity.Magnitude > 0.05 then -- Trigger the codeblock that applies drag equation
		local speed = linearVelocity.Magnitude
		local rawDragForce = speed ^ 1.2 * self.Config.Drag * mass

		local appliedForce = baselineForce + directionForce
		local maxDragForce = appliedForce.Magnitude

		local maxStoppingForce = (mass * speed) / dt

		local dragForce = math.clamp(rawDragForce, 0, math.min(maxDragForce, maxStoppingForce))

		local dragVector = -linearVelocity.Unit * dragForce
		vectorForce += dragVector
	end

	self.VectorForce.Force = vectorForce -- Apply calculated vectorforce
end

function Regular:Movement(dt)
	local rawInputVector = rawInput.GetLocalPlayerMoveVector(self.Player) --Get the current character movement input
	self.xAxis = math.round(rawInputVector.X)
	self.yAxis = math.round(rawInputVector.Y)
	
	local deltaTurn = rawInput.GetCameraDelta() * 10 -- Get x mouse rotation
	local decay = math.sign(self.CameraTurn) * dt * 10 -- Amount to reduce from input
	self.CameraTurn = math.abs(decay) >= math.abs(self.CameraTurn) and deltaTurn 
					  or math.clamp(self.CameraTurn - decay+deltaTurn, -math.pi, math.pi) -- Apply the turn decay
	
	local targetYaw = (-math.sign(self.xAxis)*2/12) -- This chunk is for the orientation of character while flying which will be give to alignorientation
	local targetRoll = self.yAxis > 0 and (-self.CameraTurn/4)*math.sign(math.abs(self.yAxis)) or 0
	local targetPitch = self.yAxis > 0 and -math.pi / 2 or 0

	local targetTilt = CFrame.fromOrientation(0, targetYaw, 0) --This chunk of the code applies the orientation of the character
		* CFrame.fromOrientation(0, 0, targetRoll) 
		* CFrame.fromOrientation(targetPitch, 0, 0)

	local lerpSpeed = 10 --Sensitivity of lerp
	local alpha = math.clamp(dt * lerpSpeed, 0, 1) 

	self.TiltForward = (self.TiltForward or CFrame.new()):Lerp(targetTilt, alpha) -- Apply it to the variable so it can be used next frame

	local x = math.abs(self.CameraTurn)>0.5 and math.sign(self.CameraTurn) or math.round(rawInputVector.X)

	self:FlightAnimationsController(x, self.yAxis) -- Set the animations depending on input
end

function Regular:MouseLock(activate) -- Enable mouse locking to the center
	self.Active = activate
	userInputService.MouseBehavior = activate and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
	userInputService.MouseIconEnabled = not activate
end

function Regular:Interface(functionName,...) -- This function is to be used by external functions to access this module
	if self._destroyed then return end
	return self.FlightInterface and self.FlightInterface:Call(functionName,...)
end

function Regular:Destroy() --Clean up
	if self._destroyed then return end
	self._destroyed = true -- Stop function calls that get triggered by async calls
	self:TriggerFlight(false) -- Disable flight

	self.FlyIdle = self.FlyIdle and self.FlyIdle:Destroy()
	self.FlyLeft = self.FlyLeft and self.FlyLeft:Destroy()
	self.FlyRight = self.FlyRight and self.FlyRight:Destroy()
	self.FlyForward = self.FlyForward and self.FlyForward:Destroy()
	self.FlyBackward = self.FlyBackward and self.FlyBackward:Destroy()

	self.AlignOrientation = self.AlignOrientation and self.AlignOrientation:Destroy()
	self.VectorForce = self.VectorForce and self.VectorForce:Destroy()

	self.Particles = self.Particles and self.Particles:Destroy()
	
	toolsModule.DestroyTool(self.GUIDObject) -- Clear from Global Cache
end


return Regular
