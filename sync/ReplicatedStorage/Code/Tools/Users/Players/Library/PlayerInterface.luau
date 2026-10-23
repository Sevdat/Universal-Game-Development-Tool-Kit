local PlayerInterface = {}
PlayerInterface.__index = PlayerInterface

local isServer = game:GetService("RunService"):IsServer()
local isStudio = game:GetService("RunService"):IsStudio()

local activePlayers = require(script.Parent.Remote).ActivePlayers

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function PlayerInterface.new(playerModule)
	local self = setmetatable({}, PlayerInterface)
	self.PlayerModule = playerModule
	
	return self
end

function PlayerInterface:Call(functionName:string,...)
	if not self.PlayerModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	
	if isStudio then error("No function named: "..functionName) end
end

function PlayerInterface:Init(player)
	self.PlayerModule:Init(player)
end

function PlayerInterface:DamagePlayer(damage)
	local humanoid = self.PlayerModule.Humanoid
	
	if isServer and humanoid.Health > 0 then
		humanoid.Health -= damage
	end

	return humanoid.Health <= 0
end

function PlayerInterface:GetHealth()
	local humanoid = self.PlayerModule.Humanoid
	if not humanoid then return 0,100 end
	
	return (humanoid.Health or 0),(humanoid.MaxHealth or 100)
end

function PlayerInterface:SetVisibility(on:boolean)
	if self.PlayerModule.Visuals and self.PlayerModule.Visuals.ShowVisuals then
		self.PlayerModule.Visuals:ShowVisuals(not on, on)
	end
end

function PlayerInterface:GetHRP()
	return self.PlayerModule.HumanoidRootPart
end

function PlayerInterface:Destroy()
	self.PlayerModule:Destroy()
end

return PlayerInterface