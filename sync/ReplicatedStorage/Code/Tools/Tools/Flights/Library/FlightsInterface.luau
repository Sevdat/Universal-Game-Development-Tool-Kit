local FlightInterface = {}
FlightInterface.__index = FlightInterface

local runService = game:GetService("RunService")
local remote = require(script.Parent.Remote)
local activeFlights = remote.ActiveFlights
local triggerFlightRemote = remote.TriggerFlightRemote

local isClient = runService:IsClient()
local isStudio = runService:IsStudio()

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function FlightInterface.new(weaponModule)
	local self = setmetatable({}, FlightInterface)
	self.FlightModule = weaponModule
	
	return self
end

function FlightInterface:Call(functionName:string,...)
	if not self.FlightModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	
	if isStudio then error("No function named: "..functionName) end
end

function FlightInterface:Init(character)
	return self.FlightModule:Init(character)
end

function FlightInterface:RequestFlight(forceState:Vector3,permitFlight:boolean?,permitRemote:boolean?)
	if permitFlight then
		self.FlightModule:TriggerFlight(forceState)
	end

	if permitRemote then 
		if isClient then
			triggerFlightRemote:FireServer(self.FlightModule.GUIDObject,forceState)
		else
			triggerFlightRemote:FireAllClients(self.FlightModule.GUIDObject,forceState)
		end
	end
end

function FlightInterface:GetFlightStates()
	local isFlying,isBoosting = self.FlightModule.IsFlying,self.FlightModule.IsBoosting
	return isFlying, isBoosting
end

function FlightInterface:Destroy()	
	self.FlightModule:Destroy()
end

return FlightInterface