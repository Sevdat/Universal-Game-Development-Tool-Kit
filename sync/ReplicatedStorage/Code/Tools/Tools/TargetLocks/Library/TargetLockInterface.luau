local TargetLockInterface = {}
TargetLockInterface.__index = TargetLockInterface

local isStudio = game:GetService("RunService"):IsStudio()

local activeTargetLocks = require(script.Parent.Remote).ActiveTargetLocks

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function TargetLockInterface.new(targetLockModule)
	local self = setmetatable({}, TargetLockInterface)
	self.TargetLockModule = targetLockModule
	
	return self
end

function TargetLockInterface:Call(functionName:string,...)
	if not self.TargetLockModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	
	if isStudio then error("No function named: "..functionName) end
end

function TargetLockInterface:Init(player,character)
	self.TargetLockModule:Init(player,character)
end

function TargetLockInterface:GetTargetPosition()
	return self.TargetLockModule:GetTargetPosition()
end

function TargetLockInterface:Destroy()
	self.TargetLockModule:Destroy()
end

return TargetLockInterface