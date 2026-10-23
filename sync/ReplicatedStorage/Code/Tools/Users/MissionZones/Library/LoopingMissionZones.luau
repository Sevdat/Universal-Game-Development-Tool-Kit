local module = {}

local runService = game:GetService("RunService")
local isServer = game:GetService("RunService"):IsServer()
local players = game:GetService("Players")

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local allMissionZones = workspace.AllMissionZones

local missionZoneParams = OverlapParams.new()
missionZoneParams.FilterType = Enum.RaycastFilterType.Include
missionZoneParams.FilterDescendantsInstances = {allMissionZones}

local CHECK_INTERVAL = 0.1
local DETECTION_RADIUS = 10
local timeAccumulator = 0

function module.Init()
	local function func(dt)
		timeAccumulator += dt

		if timeAccumulator <= CHECK_INTERVAL then return end
		timeAccumulator = 0

		for _, player in ipairs(players:GetPlayers()) do
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

			if not hrp then continue end
			local missionZonesInRange = workspace:GetPartBoundsInRadius(hrp.Position, DETECTION_RADIUS, missionZoneParams)

			for _, activationZone in ipairs(missionZonesInRange) do
				local missionZoneModule = toolsModule.GetTool(activationZone.Parent)
				if not missionZoneModule then return end
				
				missionZoneModule:Interface("AddHRPInZone",player,hrp)
				missionZoneModule:Interface("ActivateNPCLoop")
			end
		end

		for _, missionZone in ipairs(allMissionZones:GetChildren()) do
			local missionZoneModule = toolsModule.GetTool(missionZone)
			if not missionZoneModule then return end
			
			missionZoneModule:Interface("LoopMissionZone",CHECK_INTERVAL)
		end
	end
	
	toolsModule.AddToLoop("Heartbeat",func)
end

return module
