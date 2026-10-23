local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

local tycoonInterface = require(script.Parent.Library.TycoonInterface)
local armourStand = require(script.Parent.Library.ArmourStand)
local remote = require(script.Parent.Library.Remote)

local isClient = game:GetService("RunService"):IsClient()

local defaultName = "Default"

local Tycoon = {}
Tycoon.__index = Tycoon

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function Tycoon.new(config,guidObject)
	local self = setmetatable({}, Tycoon)

	self.Config = config

	self.Tycoon = nil
	self.TycoonOwner = nil
	
	self.OwnerName = nil

	self.ArmourStands = {}

	self.GUIDObject = guidObject
	
	self.TycoonInterface = tycoonInterface.new(self)
	
	self.GUIDObjectDestroyingConnection = self.GUIDObjectDestroyingConnection or self.GUIDObject.Destroying:Connect(function()
		self:Interface("Destroy")
	end)
	
	self._destroyed = false

	return self
end

function Tycoon:Init(tycoon)
	self.Tycoon = tycoon
	
	self.Values = self.Tycoon:FindFirstChild("Values")
	self.OwnerUserId = self.Values:FindFirstChild("OwnerUserId")
	self.TycoonOwner = self.OwnerUserId.Value ~= "" and players:GetPlayerByUserId(tonumber(self.OwnerUserId.Value))
	self:SetTycoonOwner(self.TycoonOwner)
	
	self.OwnerName = self.Tycoon:FindFirstChild("OwnerName"):FindFirstChild("BillboardGui"):FindFirstChild("Name")
	self.OwnerName.Text = self.TycoonOwner and self.TycoonOwner.Name or ""

	for i, floorModel in ipairs(self.Tycoon:GetChildren()) do
		if floorModel.Name:match("^Floor") then
			local armourStandsFolder = floorModel.ArmourStands
			for i,armourStandModel in ipairs(armourStandsFolder:GetChildren()) do
				local armourStandTable = armourStand.new(self,armourStandModel)
				self.ArmourStands[armourStandModel.Name] = armourStandTable

				armourStandTable:Init(self.TycoonOwner)
			end
		end
	end

	self.OwnerChangedConnection = self.OwnerChangedConnection or self.OwnerUserId.Changed:Connect(function(newOwner)
		self.TycoonOwner = newOwner ~= "" and players:GetPlayerByUserId(tonumber(newOwner)) or nil
		self:SetTycoonOwner(self.TycoonOwner)
		self.OwnerName.Text = self.TycoonOwner and self.TycoonOwner.Name or ""
	end)
	
	toolsModule.SetToolAttribute(self.Tycoon,self.GUIDObject.Value)
end

function Tycoon:SetTycoonOwner(player)
	self.TycoonOwner = player

	for _,armourStandTable in pairs(self.ArmourStands) do
		armourStandTable:Init(self.TycoonOwner)
	end
end

function Tycoon:InsertToArmourStand(guidObject)
	if not guidObject then return false end
	
	for armourStandName,armourStandTable in pairs(self.ArmourStands) do
		if not armourStandTable:HasArmour() then
			armourStandTable:InsertArmour(guidObject)
			return true
		end
	end
	
	return false
end

function Tycoon:HasFreeArmourStand()
	for _,armourStandTable in pairs(self.ArmourStands) do
		if not armourStandTable:HasArmour() then
			return true
		end
	end
	
	return false
end

function Tycoon:Rebirth()
	for _,armourStandTable in pairs(self.ArmourStands) do
		armourStandTable:Rebirth()
	end
end

function Tycoon:Interface(functionName,...)
	if self._destroyed then return end
	return self.TycoonInterface and self.TycoonInterface:Call(functionName,...)
end

function Tycoon:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	
	self.OwnerChangedConnection = self.OwnerChangedConnection and self.OwnerChangedConnection:Disconnect()
	
	for armourStandName,armourStandTable in pairs(self.ArmourStands) do
		armourStandTable:Destroy()
		self.ArmourStands[armourStandName] = nil
	end
	
	self.ArmourStands = nil
	
	toolsModule.DestroyTool(self.GUIDObject)
end

return Tycoon