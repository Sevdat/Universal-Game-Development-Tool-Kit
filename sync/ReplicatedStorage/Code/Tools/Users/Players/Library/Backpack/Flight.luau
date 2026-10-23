local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local function addFlight(backPackModule,toolTable)
	local guidObject = toolTable.GUIDObject
	local tools = backPackModule.Tools
	local character = backPackModule.Character
	local player = backPackModule.Player
	
	local flightData = toolsModule.GetData(player,{"Player","Flight"})

	flightData.Value = guidObject.Name

	tools.Flight = toolTable
	tools.Flight:Interface("Init",character)
end

local function removeFlight(backPackModule)
	local player = backPackModule.Player
	
	local flightData = toolsModule.GetData(player,{"Player","Flight"})

	flightData.Value = ""
	backPackModule.Tools.Flight = nil
end

function module.Init(backPackModule)
	local tools = backPackModule.Tools
	local player = backPackModule.Player
	local character = backPackModule.Character

	local toolTable = toolsModule.InitTool(player,{"Player","Flight"},character)

	if not toolTable then return end

	addFlight(backPackModule,toolTable)
end

function module.GiveOrTake(backPackModule,added,toolTable)	
	if added then
		addFlight(backPackModule,toolTable)
	else
		removeFlight(backPackModule)
	end
end

function module.TriggerFlightFunction(backPackModule)
	return function()
		local flightTable = backPackModule.Tools.Flight
		local cameraTable = backPackModule.Tools.Camera
		if flightTable then		
			local isFlying = flightTable.IsFlying
			
			flightTable:Interface("RequestFlight",not isFlying,false,true)
			cameraTable:Interface("EnableSpring",isFlying)
			cameraTable:Interface("EnableSmoothing",not isFlying)
			cameraTable:Interface("EnableDepthView",not isFlying)
		end
	end
end

return module
