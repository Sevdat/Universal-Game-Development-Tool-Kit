local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local isServer = game:GetService("RunService"):IsServer()
local collectionService = game:GetService("CollectionService")

local allMissionZones = workspace.AllMissionZones

function module.InitFolders()

	local missionZones = collectionService:GetTagged("MissionZone")
	
	local function initMissionZone(missionZone)
		local allTools = toolsModule.GetAllTools(missionZone,{MissionZones = true},true)
		local toolTable = allTools.MissionZones and allTools.MissionZones[1]

		if toolTable then
			toolTable:Interface("Init",missionZone)
			missionZone.Parent = allMissionZones
		end
	end
	
	local function destroyMissionZone(missionZone)
		local guidObject = toolsModule.GetGUIDObject(missionZone)
		if guidObject then guidObject:Destroy() end
	end

	for _, missionZone in ipairs(missionZones) do
		if not missionZone:IsDescendantOf(workspace) then continue end
		initMissionZone(missionZone)
	end
	
	allMissionZones.ChildAdded:Connect(initMissionZone)
	allMissionZones.ChildRemoved:Connect(destroyMissionZone)

end

return module
