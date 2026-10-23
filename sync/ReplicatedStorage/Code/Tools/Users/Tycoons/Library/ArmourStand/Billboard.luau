local tween = require(script.Parent.Tween)
local suffix = require(script.Parent.Suffix)
local calculations = require(script.Parent.Calculations)
local spatialSounds = require(script.Parent.SpatialSounds)
local rarityColor = require(script.RarityColor)

local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local Billboard = {}
Billboard.__index = Billboard

function Billboard.new(armourStand,getArmourInterface)
	local self = setmetatable({}, Billboard)

	self.TycoonOwner = nil

	self.ArmourStand = armourStand

	self.GetArmourInterface = getArmourInterface
	
	self.Identity = nil
	self.Stats = nil
	
	self.Name = nil
	self.Rarity = nil
	self.Level = nil
	
	self.Health = nil
	self.Income = nil

	return self
end

function Billboard:Init(tycoonOwner)
	self.TycoonOwner = tycoonOwner
	
	self.Identity = self.ArmourStand.Stand.Identity.BillboardGui
	self.Stats = self.ArmourStand.Stand.Stats.BillboardGui

	self.Name = self.Identity.Frame:FindFirstChild("Name")
	self.Rarity = self.Identity.Frame.Rarity
	self.Level = self.Identity.Frame.Level

	self.Health = self.Stats.Frame.Health.Amount
	self.Income = self.Stats.Frame.Income.Amount
end

function Billboard:UpdateText()
	if not isClient then return end
	local name = self.GetArmourInterface("GetName") or "Empty"
	local rarity = self.GetArmourInterface("GetRarity") or "-"
	local level = self.GetArmourInterface("GetLevel") or 0
	local health = self.GetArmourInterface("GetHealth") or 0
	local income = self.GetArmourInterface("GetIncome") or 0
	
	self.Name.Text = name
	self.Rarity.Text = rarity
	
	local rarityColor = rarityColor[rarity] or Color3.fromRGB(255,255,255)
	self.Rarity.TextColor3 = rarityColor
	
	self.Level.Text = "Level "..level
	
	self.Health.Text = health
	self.Income.Text = suffix.Shorten(calculations.CalculateIncome(income,level)).."/s"
end


function Billboard:Destroy()

	table.clear(self)
	setmetatable(self, nil)
end

return Billboard