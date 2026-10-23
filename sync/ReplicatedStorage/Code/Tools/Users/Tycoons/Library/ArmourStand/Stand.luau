local calculations = require(script.Parent.Calculations)

local isClient = game:GetService("RunService"):IsClient()

local Stand = {}
Stand.__index = Stand

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function Stand.new(armourStand)
	local self = setmetatable({}, Stand)

	self.ArmourStand = armourStand

	self.TycoonOwner = nil

	self.Armour = nil
	self.ArmourTable = nil
	self.GUIDObject = nil

	self.InstantEquip = true 

	return self
end

function Stand:Init(player:Players?)
	self.Armour = self.ArmourStand.Stand.Armour

	self.TycoonOwner = player

	for i,e in ipairs(self.Armour:GetChildren()) do
		if e:IsA("BasePart") then
			e.Transparency = 1
		end
	end
end

function Stand:GetArmourInterface()
	return function(funcName,variable)
		return self.ArmourTable and self.ArmourTable:Interface(funcName,variable)
	end
end

function Stand:ResetStand(forceReset)
	if forceReset or not self.TycoonOwner and self.GUIDObject then
		self.ArmourTable = self.GUIDObject and self.GUIDObject:Destroy()
		self.GUIDObject = nil
	end
end

function Stand:CreateArmour()	
	local toolTable = toolsModule.InitTool(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name},self.Armour)

	return toolTable and toolTable.GUIDObject
end

function Stand:Added(toolTable)
	self.ArmourTable = toolTable
	self.GUIDObject = toolTable.GUIDObject

	local saveLevel = toolsModule.GetData(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name,"Level"})
	local armourLevel = self.ArmourTable:Interface("GetLevel")

	if armourLevel > saveLevel.Value then
		saveLevel.Value = armourLevel
	end

	self.ArmourTable:Interface("SetLevel",saveLevel.Value)

	self.ArmourTable:Interface("Init",self.Armour,self.InstantEquip)
	toolsModule.UpdateData(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name},self.GUIDObject.Name)
	toolsModule.UpdateData(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name,"Level"},saveLevel.Value)
	self.InstantEquip = true
end

function Stand:Removed()
	self.GUIDObject = nil
	self.ArmourTable = nil
	toolsModule.UpdateData(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name},"")
	toolsModule.UpdateData(self.TycoonOwner,{"Tycoon",self.ArmourStand.Name,"Level"},0)
	self.InstantEquip = true
end

function Stand:GiveArmour(player,armourData)
	self.InstantEquip = false
	
	if not self.ArmourTable and armourData then
		armourData.GUIDObject.Parent = self.Armour
	elseif self.ArmourTable and not armourData then
		self.GUIDObject.Parent = player.Character
	end
end

function Stand:PromptStealArmour(stealingPlayer)
	local standGUIDObject = self.GUIDObject
	if not standGUIDObject then return end
	
	toolsModule.StealPrompt(stealingPlayer,self:GetRarity(),function()
		local stealerTycoonGUID = toolsModule.GetData(stealingPlayer,{"Tycoon","OwnedTycoon"}).Value
		local stealerTycoonTable = toolsModule.GetTool(stealerTycoonGUID)
		
		if not stealerTycoonTable then return end

		local allTools = toolsModule.GetAllTools(stealingPlayer.Character,{Armours = true})
		local stealerArmourTable = allTools.Armours and allTools.Armours[1]

		if stealerArmourTable then
			if stealerTycoonTable:HasFreeArmourStand() then
				stealerTycoonTable:InsertToArmourStand(stealerArmourTable.GUIDObject)
			else
				stealerArmourTable.GUIDObject:Destroy()
			end
		end

		standGUIDObject.Parent = stealingPlayer.Character
	end)
end

function Stand:GetSellPrice()
	if not self.ArmourTable then return 0 end
	local sell = self.ArmourTable:Interface("GetSell") or 0
	local level = self.ArmourTable:Interface("GetLevel") or 1
	return calculations.CalculateSell(sell,level)
end

function Stand:SellArmour()
	local armourTable = self.ArmourTable
	if armourTable then
		self.GUIDObject.Parent = nil
		self.GUIDObject = self.GUIDObject and self.GUIDObject:Destroy()
		local cash = toolsModule.GetData(self.TycoonOwner,{"Player","Cash"})
		if not cash then return end
		cash.Value += self:GetSellPrice()
	end
end

function Stand:GetRarity()
	return self.ArmourTable and self.ArmourTable:Interface("GetRarity") or "Empty"
end

function Stand:HasArmour()
	return self.ArmourTable and true or false
end

function Stand:InsertArmour(guidObject)
	if guidObject then
		guidObject.Parent = self.Armour
	end
end

function Stand:Destroy()
	self.ArmourTable = self.GUIDObject and self.GUIDObject:Destroy()
	
	table.clear(self)
	setmetatable(self, nil)
end

return Stand