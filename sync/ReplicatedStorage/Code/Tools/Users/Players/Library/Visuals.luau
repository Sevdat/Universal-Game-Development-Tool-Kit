
local isClient = game:GetService("RunService"):IsClient()
local localPlayer = isClient and game:GetService("Players").LocalPlayer
local damageVisual = require(script.DamageVisual)

local Visuals = {}
Visuals.__index = Visuals

function Visuals.new(player)
	local self = setmetatable({}, Visuals)

	if not isClient or self.Player == localPlayer then return self end
	
	self.Player = player
	self.Character = nil
	self.Humanoid = nil
	self.HumanoidRootPart = nil
	
	self.Highlight = script.Highlight:Clone()
	self.HealthAndName = script.HealthAndName:Clone()
	self.EnemyIdentifier = script.EnemyIdentifier:Clone()

	return self
end

function Visuals:Init(character,humanoid,humanoidRootPart)
	if not isClient or self.Player == localPlayer then return end
	
	self.Character = character
	self.Humanoid = humanoid
	self.HumanoidRootPart = humanoidRootPart

	self.Highlight.Parent = self.Character
	self.HealthAndName.Parent = self.HumanoidRootPart
	self.EnemyIdentifier.Parent = self.HumanoidRootPart
	
	self.Humanoid.HealthChanged:Connect(function(currentHealth)
		self:OnHealthChanged(currentHealth)
	end)
	
	self:ShowVisuals(true,false)
end

function Visuals:ShowVisuals(activate1,activate2)
	self.EnemyIdentifier.Enabled = activate1

	self.Highlight.Enabled = activate2
	self.HealthAndName.Enabled = activate2
end

function Visuals:OnHealthChanged(currentHealth)
	if currentHealth <= 0 then
		self.Tween = damageVisual.Tween(0,self.Humanoid.MaxHealth,self.Tween,self.HealthAndName)
		return
	end

	if self.HealthAndName and not self.HealthAndName.Enabled then return end
	self.Tween = damageVisual.Tween(currentHealth,self.Humanoid.MaxHealth,self.Tween,self.HealthAndName)
end

function Visuals:Destroy()
	self.Tween = self.Tween and self.Tween:Cancel()

	table.clear(self)
	setmetatable(self, nil)
end

return Visuals
