local CameraInterface = {}
CameraInterface.__index = CameraInterface

local isStudio = game:GetService("RunService"):IsStudio()

local activeCameras = require(script.Parent.Remote).ActiveCameras

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function CameraInterface.new(cameraModule)
	local self = setmetatable({}, CameraInterface)
	self.CameraModule = cameraModule

	return self
end

function CameraInterface:Call(functionName:string,...)
	if not self.CameraModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	
	if isStudio then error("No function named: "..functionName) end
end

function CameraInterface:Init(character)
	return self.CameraModule:Init(character)
end

function CameraInterface:Trigger(enable)
	self.CameraModule:Trigger(enable)
end

function CameraInterface:EnableOffset(enable)
	self.CameraModule.OffsetEnabled = enable
end

function CameraInterface:EnableSmoothing(enable)
	self.CameraModule.SmoothingEnabled = enable
end

function CameraInterface:EnableSpring(enable)
	self.CameraModule.SpringEnabled = enable
end

function CameraInterface:EnableDepthView(enable)
	self.CameraModule.DepthViewEnabled = enable
end

function CameraInterface:Destroy()
	self.CameraModule:Destroy()
end

return CameraInterface