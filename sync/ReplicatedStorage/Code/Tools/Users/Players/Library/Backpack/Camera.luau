local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local function addCamera(backPackModule,toolTable)
	local guidObject = toolTable.GUIDObject
	local tools = backPackModule.Tools
	local character = backPackModule.Character
	local player = backPackModule.Player
	
	local cameraData = toolsModule.GetData(player,{"Player","Camera"})

	cameraData.Value = guidObject.Name

	tools.Camera = toolTable
	tools.Camera:Interface("Init",character)
end

local function removeCamera(backPackModule)
	local player = backPackModule.Player
	
	local cameraData = toolsModule.GetData(player,{"Player","Camera"})

	cameraData.Value = ""
	backPackModule.Tools.Camera = nil
end

function module.Init(backPackModule)
	local tools = backPackModule.Tools
	local player = backPackModule.Player
	local character = backPackModule.Character

	local toolTable = toolsModule.InitTool(player,{"Player","Camera"},character)

	if not toolTable then return end
	
	addCamera(backPackModule,toolTable)
end

function module.GiveOrTake(backPackModule,added,toolTable)	
	if added then
		addCamera(backPackModule,toolTable)
	else
		removeCamera(backPackModule)
	end
end


return module
