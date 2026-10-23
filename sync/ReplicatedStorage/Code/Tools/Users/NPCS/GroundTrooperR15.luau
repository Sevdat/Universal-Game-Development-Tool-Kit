local debris = game:GetService("Debris")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")

local npcInterface = require(script.Parent.Library.NPCInterface)
local serverNPC = require(script.Library.ServerNPC)
local clientNPC = require(script.Library.ClientNPC)
local HRPSearch = require(script.Parent.Library.HRPSearch)
local missionZoneSearch = require(script.Parent.Library.MissionZoneSearch)
local rewardsManager = require(script.Parent.Library.RewardsManager)

local allNPC = workspace.AllNPC
local clientModels = allNPC.ClientModels
local serverModels = allNPC.ServerModels

local isClient = game:GetService("RunService"):IsClient()

local GroundTrooperR15 = {}
GroundTrooperR15.__index = GroundTrooperR15

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function GroundTrooperR15.new(config,guidObject)
	local self = setmetatable({}, GroundTrooperR15)

	self.Config = config

	self.LastLoopTime = 0
	self.TargetScanCountdown = 0
	self.NextRespawnTime = 0

	self.Alive = false
	self.ServerNPC = nil

	self.ClientNPC = nil
	self.OnHealthChanged = nil

	self.Weapon = nil
	
	self.DropRewardFlag = false

	self.GUIDObject = guidObject
	
	self.NPCInterface = npcInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function GroundTrooperR15:Init(serverModel)
	self.ServerNPC = serverNPC.new(self,serverModel)
	self.ServerNPC:Init()
	
	self.ClientNPC = self.ClientNPC or clientNPC.new(self,serverModel)
	
	local allTools = toolsModule.GetAllTools(serverModel,{Weapons = true},true)
	self.Weapon = allTools and allTools.Weapons and allTools.Weapons[1]
	
	if self.ServerNPC.Health.Value > 0 then
		self:Respawn()
	end
	
	self.OnHealthChanged = self.OnHealthChanged or self.ServerNPC.Health.Changed:Connect(function(currentHealth)

		local killed = self.Alive and currentHealth <= 0
		
		self.Alive = currentHealth >0

		if not isClient and killed and self.DropRewardFlag then
			self:DropReward()
		end
		
		if killed then
			if self.Weapon then
				self.Weapon:Interface("Init",nil)
				self.Weapon:Interface("RequestEquip",false,true,true)
			end
		end
		
		if self.ClientNPC and self.ClientNPC.OnHealthChanged then
			self.ClientNPC:OnHealthChanged(currentHealth,self.Config.MaxHealth)
		end
	end)
end

function GroundTrooperR15:DropReward()
	local position = self.ServerNPC.Hitbox.Position
	local toolTable = toolsModule.GetTool(missionZoneSearch.GetMissionZone(self.ServerNPC.Hitbox))

	if not toolTable then return end
	
	local zonePart =  toolTable:Interface("GetArea")
	
	rewardsManager.DropReward(position)
	
	self.DropRewardFlag = false

	toolTable:Interface("NPCKilled")
end

function GroundTrooperR15:Respawn()
	if self.Alive then return false end
	self.DropRewardFlag = true

	if isClient then
		self.ClientNPC:Respawn()
	else
		self.ServerNPC.Health.Value = self.Config.MaxHealth
	end
	
	if self.Weapon then
		self.Weapon:Interface("Init",self[isClient and "ClientNPC" or "ServerNPC"].Model)
		self.Weapon:Interface("RequestEquip",true,true,true)
	end

	self.Alive = true
	return true
end

function GroundTrooperR15:Despawn()
	self.DropRewardFlag = false
	self.ServerNPC.Health.Value = 0
end

function GroundTrooperR15:MovementLogic()
	if self.ServerNPC.Health.Value <= 0 then return end

	if isClient then
		if self.ClientNPC then
			self.ClientNPC:Movement()
		end
	else
		self.ServerNPC:Movement()
	end
end

function GroundTrooperR15:Aim()
	if isClient	then return end
	
	if self.ServerNPC.Health.Value == 0 then return end

	if not self.Weapon then return end

	local target = self.ServerNPC.TargetHRP.Value
	if target then
		local lookAtShooterCFrame = CFrame.lookAt(target.Position, self.ServerNPC.Hitbox.Position)

		local localVelocity = lookAtShooterCFrame:VectorToObjectSpace(target.AssemblyLinearVelocity)

		local speed = self.Weapon:Interface("GetVariable","Speed") or 100

		local timeToImpact = (target.Position - self.ServerNPC.Hitbox.Position).Magnitude / speed

		local leadVectorLocal = Vector3.new(localVelocity.X, localVelocity.Y, 0)

		local leadVectorWorld = lookAtShooterCFrame:VectorToWorldSpace(leadVectorLocal * timeToImpact)
		local predictedPos = target.Position + leadVectorWorld
		self.Weapon:Interface("RequestSetAim",predictedPos,target,true,true)
	else
		self.Weapon:Interface("RequestSetAim",nil,nil,true,true)
	end
end

function GroundTrooperR15:Shoot()
	if self.ServerNPC.Health.Value == 0 then return end

	if not self.Weapon then return end
	
	local pullTrigger = self.ServerNPC.TargetHRP.Value and true or false
	
	self.Weapon:Interface("RequestShoot",pullTrigger,true,false)
end

function GroundTrooperR15:ScanForTarget(dt,humanoidRootParts)
	if isClient then return end

	self.TargetScanCountdown -= dt
	
	local timeNow = workspace:GetServerTimeNow()
	
	if timeNow - self.LastLoopTime > 2 then
		self.ServerNPC.TargetHRP.Value = nil
	end
	
	self.LastLoopTime = timeNow
	
	if self.TargetScanCountdown <= 0 then
		self.TargetScanCountdown = math.random(0,1000)/1000
		self.ServerNPC.TargetHRP.Value = HRPSearch.GetHRPInArea(self.ServerNPC.Hitbox, humanoidRootParts)
	end
end

function GroundTrooperR15:LoopNPC(dt,humanoidRootParts)	
	dt = dt or 0.1

	if self.Alive then		
		self:ScanForTarget(dt,humanoidRootParts)
		self:MovementLogic()
		self:Aim()
		self:Shoot()
	end
end

function GroundTrooperR15:Interface(functionName,...)
	if self._destroyed then return end
	return self.NPCInterface and self.NPCInterface:Call(functionName,...)
end

function GroundTrooperR15:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	
	self.OnHealthChanged = self.OnHealthChanged and self.OnHealthChanged:Disconnect()
	self.ServerNPC = self.ServerNPC and self.ServerNPC:Destroy()
	self.ClientNPC = self.ClientNPC and self.ClientNPC:Destroy()
	
	local weaponGUIDObject = self.Weapon and self.Weapon.GUIDObject
	if weaponGUIDObject then
		weaponGUIDObject:Destroy()
	end
	
	toolsModule.DestroyTool(self.GUIDObject)
end

return GroundTrooperR15