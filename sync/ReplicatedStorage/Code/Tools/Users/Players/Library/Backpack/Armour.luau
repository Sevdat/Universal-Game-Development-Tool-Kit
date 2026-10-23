local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local function addArmour(backPackModule,toolTable,instantEquip)
	local guidObject = toolTable.GUIDObject
	local tools = backPackModule.Tools
	local player = backPackModule.Player
	local character = backPackModule.Character
	
	local armourData = toolsModule.GetData(player,{"Player","Armour"})
	local levelData = toolsModule.GetData(player,{"Player","Armour","Level"})
	
	armourData.Value = guidObject.Name
	levelData.Value = toolTable.Level
	
	toolTable:Interface("SetLevel",levelData.Value)
	toolTable:Interface("Init",character,instantEquip)

	tools.Armour = toolTable
end

local function removeArmour(backPackModule)
	local player = backPackModule.Player
	
	local armourData = toolsModule.GetData(player,{"Player","Armour"})
	local levelData = toolsModule.GetData(player,{"Player","Armour","Level"})

	armourData.Value = ""
	levelData.Value = 1

	backPackModule.Tools.Armour = nil
end

function module.Init(backPackModule)
	local tools = backPackModule.Tools
	local player = backPackModule.Player
	local character = backPackModule.Character

	local toolTable = toolsModule.InitTool(player,{"Player","Armour"},character)
	
	if not toolTable then return end

	toolTable:Interface("SetLevel",toolsModule.GetData(player,{"Player","Armour","Level"}).Value)
	
	addArmour(backPackModule,toolTable,true)
end

function module.GiveOrTake(backPackModule,added,toolTable)	
	if added then		
		addArmour(backPackModule,toolTable,false)
	else
		removeArmour(backPackModule)
	end
end

return module
