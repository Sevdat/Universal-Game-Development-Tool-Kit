local damageVisual = require(script.DamageVisual)
local movement = require(script.Movement)
local destruction = require(script.Destruction)

local clientModels = workspace.AllNPC.ClientModels

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local ClientNPC = {}
ClientNPC.__index = ClientNPC

--config,clientDummy,targetHRP,serverPart

function ClientNPC.new(npcTable,serverDummy)
	local self = setmetatable({}, ClientNPC)
	
	self.NPCTable = npcTable
	self.Config = npcTable.Config
	self.GUIDObject = self.NPCTable.GUIDObject
	self.ServerPart = serverDummy:FindFirstChild("Hitbox")
	self.TargetHRP = self.ServerPart:FindFirstChild("TargetHRP")
	
	self.Scale = nil
	self.HumanoidRootPart = nil
	self.Humanoid = nil
	self.Animator = nil
	self.AlignOrientation = nil
	
	self.RunAnimationTrack = nil
	self.IdleAnimationTrack = nil

	self.Highlight = nil
	self.HealthAndName = nil
	self.EnemyIdentifier = nil
	
	self.IsDead = true

	return self
end

function ClientNPC:Respawn()
	if not self.IsDead then return end
	
	self.Model = self.Config.ClientModel:Clone()
	self.Model:PivotTo(self.ServerPart.CFrame)
	self.Scale = self.Model:GetScale()
	self.HumanoidRootPart = self.Model:FindFirstChild("HumanoidRootPart")
	self.Humanoid = self.Model:FindFirstChild("Humanoid")
	self.Animator = self.Humanoid:FindFirstChild("Animator")
	self.AlignOrientation = self.HumanoidRootPart:FindFirstChild("AlignOrientation")
	self.Highlight = self.Model:FindFirstChild("Highlight")
	self.HealthAndName = self.HumanoidRootPart:FindFirstChild("HealthAndName")
	self.EnemyIdentifier = self.HumanoidRootPart:FindFirstChild("EnemyIdentifier")

	self.Humanoid.WalkSpeed = self.Config.Speed
	toolsModule.SetToolAttribute(self.Model,self.GUIDObject.Value)

	self.Model.Parent = clientModels

	self.RunAnimationTrack = self.Animator:LoadAnimation(self.Config.Run)
	self.RunAnimationTrack.Looped = true

	self.IdleAnimationTrack = self.Animator:LoadAnimation(self.Config.Idle)
	self.IdleAnimationTrack.Looped = true

	self:ShowVisuals(true,false)
	
	self.IsDead = false
end

function ClientNPC:ShowVisuals(activate1,activate2)
	if self.IsDead then return end
	
	self.EnemyIdentifier.Enabled = activate1

	self.Highlight.Enabled = true
	self.HealthAndName.Enabled = activate2
end

function ClientNPC:OnHealthChanged(currentHealth,maxHealth)
	if self.IsDead then return end
	
	if currentHealth <= 0 then
		self.IsDead = true
		self.Tween = damageVisual.Tween(0,100,self.Tween,self.HealthAndName)
		destruction.DestroyClientNPC(self.Model)

		self.RunAnimationTrack = self.RunAnimationTrack and self.RunAnimationTrack:Destroy()
		self.IdleAnimationTrack = self.IdleAnimationTrack and self.IdleAnimationTrack:Destroy()
	else
		self.Tween = damageVisual.Tween(currentHealth,maxHealth,self.Tween,self.HealthAndName)
	end
end

function ClientNPC:Movement()
	if self.IsDead then return end
	
	movement.MovementLogicClient(
		self.HumanoidRootPart,
		self.Humanoid,
		self.AlignOrientation,
		self.ServerPart,
		self.TargetHRP.Value,
		self.IdleAnimationTrack,
		self.RunAnimationTrack,
		self.Scale
	)
end

function ClientNPC:Destroy()
	self.IsDead = true

	self.Model = self.Model and self.Model:Destroy()
	self.RunAnimationTrack = self.RunAnimationTrack and self.RunAnimationTrack:Destroy()
	self.IdleAnimationTrack = self.IdleAnimationTrack and self.IdleAnimationTrack:Destroy()
	
	task.delay(5,function()
		setmetatable(self, nil)
		table.clear(self)
		table.freeze(self)
	end)
end


return ClientNPC


--function module.DamageVisual(healthAndName,maxHealth,currentHealth)
--	local healthbar = healthAndName:FindFirstChild("HealthBar")
--	local health = healthbar:FindFirstChild("Health")
--	local damage = healthbar:FindFirstChild("Damage")

--	if currentHealth>0 then
--		local currentHealth = currentHealth/maxHealth
--		local healthSize = health.Size.X.Scale
--		local healthOffset = healthSize - currentHealth

--		local damagePosition = damage.Position.X.Scale
--		local damageSize = damage.Size.X.Scale

--		health.Size = UDim2.new(currentHealth,0,1,0)
--		damage.Position = UDim2.new(currentHealth,0,0,0)
--		local decrease = lerp(damageSize + healthOffset,0,0.027)
--		damage.Size = UDim2.new(decrease,0,1,0)
--	else
--		health.Size = UDim2.new(0,0,1,0)
--		damage.Position = UDim2.new(0,0,0,0)
--		damage.Size = UDim2.new(math.clamp(0,0,1),0,1,0)
--	end
--end