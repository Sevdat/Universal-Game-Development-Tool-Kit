local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local function addTargetLock(backPackModule,toolTable)
	local guidObject = toolTable.GUIDObject
	local tools = backPackModule.Tools
	local player = backPackModule.Player
	local character = backPackModule.Character
	
	local targetLockData = toolsModule.GetData(player,{"Player","TargetLock"})

	targetLockData.Value = guidObject.Name

	tools.TargetLock = toolTable
	tools.TargetLock:Interface("Init",player,character)
end

local function removeTargetLock(backPackModule)
	local player = backPackModule.Player
	
	local targetLockData = toolsModule.GetData(player,{"Player","TargetLock"})

	targetLockData.Value = ""
	backPackModule.Tools.TargetLock = nil
end

function module.Init(backPackModule)
	local tools = backPackModule.Tools
	local player = backPackModule.Player
	local character = backPackModule.Character

	local toolTable = toolsModule.InitTool(player,{"Player","TargetLock"},character)

	if not toolTable then return end

	addTargetLock(backPackModule,toolTable)
end

function module.GiveOrTake(backPackModule,added,toolTable)	
	if added then
		addTargetLock(backPackModule,toolTable)
	else
		removeTargetLock(backPackModule)
	end
end

return module
