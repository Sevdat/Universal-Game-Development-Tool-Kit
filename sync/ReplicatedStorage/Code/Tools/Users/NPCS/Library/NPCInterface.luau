local NPCInterface = {}
NPCInterface.__index = NPCInterface

local isStudio = game:GetService("RunService"):IsStudio()
local isServer = game:GetService("RunService"):IsServer()

local dropRewardRemote = require(script.Parent.Remote).DropRewardRemote

local activeNPCS = require(script.Parent.Remote).ActiveNPCS

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function NPCInterface.new(npcModule)
	local self = setmetatable({}, NPCInterface)
	self.NPCModule = npcModule
	
	return self
end

function NPCInterface:Call(functionName:string,...)
	if not self.NPCModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	
	if isStudio then error("No function named: "..functionName) end
end

function NPCInterface:Init(serverModel)
	self.NPCModule:Init(serverModel)
end

function NPCInterface:DamageNPC(damage)
	local serverNPC = self.NPCModule.ServerNPC

	if isServer and serverNPC.Health.Value > 0 then
		serverNPC.Health.Value -= damage
	end

	return serverNPC.Health.Value <= 0
end

function NPCInterface:GetHealth()
	local serverNPC = self.NPCModule.ServerNPC
	if not serverNPC then return 0 end
	
	return (serverNPC.Health and serverNPC.Health.Value or 0),(self.NPCModule.MaxHealth or 100)
end

function NPCInterface:SetVisibility(on:boolean)
	local clientNPC = self.NPCModule.ClientNPC
	if not clientNPC then return end
	
	clientNPC:ShowVisuals(not on, on)
end

function NPCInterface:GetHRP()
	local clientNPC = self.NPCModule.ClientNPC
	if not clientNPC then return end
	
	return clientNPC.HumanoidRootPart
end

function NPCInterface:LoopNPC(dt:number,humanoidRootParts)
	self.NPCModule:LoopNPC(dt,humanoidRootParts)
end

function NPCInterface:Respawn()
	self.NPCModule:Respawn()
end

function NPCInterface:Despawn()
	self.NPCModule:Despawn()
end

function NPCInterface:DropReward()
	self.NPCModule:DropReward()
	if isServer then
		dropRewardRemote:FireAllClients(self.NPCModule.GUIDObject)
	end
end

function NPCInterface:Destroy()
	self.NPCModule:Destroy()
end

return NPCInterface