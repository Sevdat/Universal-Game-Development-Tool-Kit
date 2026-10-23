local module = {}

local isClient = game:GetService("RunService"):IsClient()
local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local function createOrCloneTool(guidObject,backPack,character)	
	local backpackTool = nil
	
	local children = {}
	local isEquipped = nil
	local index = nil

	table.move(character:GetChildren(), 1, -1, 1, children)
	index = #children
	table.move(backPack:GetChildren(), 1, -1, #children + 1, children)
	
	for i,child in children do
		local tool = child:IsA("Tool") and child
		local GUID = tool and tool:FindFirstChild("GUIDObject")
		GUID = GUID and GUID.Value
		
		if GUID and GUID == guidObject.Value then
			backpackTool = tool
			index = isEquipped<=i
			break
		end
	end
	
	if not isClient and not backpackTool then
		local _,_,configName = toolsModule.GetToolIdentifier(guidObject.Name)
		backpackTool = script.Tool:Clone()
		backpackTool.Name = configName
		backpackTool.GUIDObject.Value = guidObject.Value
	end
	
	return backpackTool, isEquipped
end


function module.Create(player,guidObject)
	if not player then return end
	
	local character = player.Character
	local backPack = player.Backpack

	local backpackTool,isEquipped = createOrCloneTool(guidObject,backPack,character)	
	local toolTable = toolsModule.GetTool(guidObject)
	
	if not isClient then
		backpackTool.Equipped:Connect(function()
			toolTable:Interface("RequestEquip",true,true,true)
		end)

		backpackTool.Unequipped:Connect(function()
			toolTable:Interface("RequestEquip",false,true,true)
		end)
	elseif isEquipped then
		toolTable:Equip(true,true)
	end

	return backpackTool
end

return module
