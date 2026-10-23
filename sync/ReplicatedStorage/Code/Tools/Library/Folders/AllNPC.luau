local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local isServer = game:GetService("RunService"):IsServer()
local collectionService = game:GetService("CollectionService")

local allNPC = workspace.AllNPC
local serverModels = allNPC.ServerModels

function module.InitFolders()
	
	local function initNPCModel(npcModel)
		local allTools = toolsModule.GetAllTools(npcModel,{NPCS = true},true)
		local toolTable = allTools.NPCS and allTools.NPCS[1]
		if toolTable then
			toolTable:Interface("Init",npcModel)
			npcModel.Parent = serverModels
		end
	end
	
	local function destroyNPC(npcModel)
		local guidObject =  toolsModule.GetGUIDObject(npcModel)
		if guidObject then guidObject:Destroy() end
	end
	
	local allNPCS = collectionService:GetTagged("NPC")

	for _, npcModel in ipairs(allNPCS) do
		if not npcModel:IsDescendantOf(workspace) then continue end
		initNPCModel(npcModel)
	end

	serverModels.ChildAdded:Connect(initNPCModel)
	serverModels.ChildRemoved:Connect(destroyNPC)

end

return module
