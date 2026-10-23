local isClient = game:GetService("RunService"):IsClient()

local TycoonInterface = {}
TycoonInterface.__index = TycoonInterface

local isStudio = game:GetService("RunService"):IsStudio()

local upgradeRemote = require(script.Parent.Remote).UpgradeRemote

local activeTycoons = require(script.Parent.Remote).ActiveTycoons

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function TycoonInterface.new(tycoonModule)
	local self = setmetatable({}, TycoonInterface)
	self.TycoonModule = tycoonModule
	
	return self
end

function TycoonInterface:Call(functionName:string,...)
	if not self.TycoonModule then return end
	
	local interfaceFunction = self[functionName]
	if interfaceFunction then
		return interfaceFunction(self,...)
	end
	
	if isStudio then error("No function named: "..functionName) end
end

function TycoonInterface:Init(tycoon)
	self.TycoonModule:Init(tycoon)
end


function TycoonInterface:GetEmptyArmourStandTable()
	return self.TycoonModule:GetEmptyArmourStandTable()
end

function TycoonInterface:Rebirth()
	return self.TycoonModule:Rebirth()
end


function TycoonInterface:RequestUpgrade(armourStandName:string,permitUpgrade:boolean?,permitRemote:boolean?)
	if not armourStandName then return end
	
	local armourStand = self.TycoonModule.ArmourStands[armourStandName]
	if permitUpgrade then
		if armourStand then
			armourStand:Upgrade()
		end
	end
	
	if permitRemote then 
		
		if isClient then
			upgradeRemote:FireServer(self.TycoonModule.GUIDObject,armourStandName)
		else
			upgradeRemote:FireAllClients(self.TycoonModule.GUIDObject,armourStandName)
		end
	end
end

function TycoonInterface:Destroy()
	self.TycoonModule:Destroy()
end

return TycoonInterface