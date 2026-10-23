local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function module.GiveArmour(player,armourPath)
	local stealerTycoonGUID = toolsModule.GetData(player,{"Tycoon","OwnedTycoon"}).Value
	local stealerTycoonTable = toolsModule.GetTool(stealerTycoonGUID)

	local armourTable = toolsModule.CreateTool(armourPath)

	stealerTycoonTable:InsertToArmourStand(armourTable.GUIDObject)

	return true
end

return module
