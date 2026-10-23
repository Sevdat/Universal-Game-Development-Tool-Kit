local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local serverModelParams = OverlapParams.new()
serverModelParams.FilterType = Enum.RaycastFilterType.Include
serverModelParams.FilterDescendantsInstances = {workspace.AllNPC.ServerModels}

function module.GetNPCSInZoneFolder(zonePart:Part,parent:Folder)
	local hitboxes = workspace:GetPartsInPart(zonePart, serverModelParams)
	
	local folder = Instance.new("Folder")
	folder.Name = "NPCS"
	
	for i,hitbox in ipairs(hitboxes) do
		local cloneGUID = toolsModule.GetGUIDObject(hitbox.Parent)
		cloneGUID = cloneGUID and cloneGUID:Clone()
		
		if cloneGUID then
			cloneGUID.Parent = folder
		end
	end
	
	folder.Parent = parent

	return folder
end

function module.LoopNPCSInZone(npcsFolder,dt,humanoidRootParts)
	for i,guidObject in ipairs(npcsFolder:GetChildren()) do
		local npcsModule = toolsModule.GetTool(guidObject.Value)
		if npcsModule then
			npcsModule:Interface("LoopNPC",dt,humanoidRootParts)
		end
	end
end

function module.RespawnNPCSInZone(npcsFolder)
	for i,guidObject in ipairs(npcsFolder:GetChildren()) do
		local npcsModule = toolsModule.GetTool(guidObject.Value)
		if npcsModule then
			npcsModule:Interface("Respawn")
		end
	end
end

function module.DespawnNPCSInZone(npcsFolder)
	for i,guidObject in ipairs(npcsFolder:GetChildren()) do
		local npcsModule = toolsModule.GetTool(guidObject.Value)
		if npcsModule then
			npcsModule:Interface("Despawn")
		end
	end
end

return module