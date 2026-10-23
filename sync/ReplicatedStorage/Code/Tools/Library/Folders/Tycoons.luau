local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local players = game:GetService("Players")
local isServer = game:GetService("RunService"):IsServer()
local collectionService = game:GetService("CollectionService")

local allTycoons = workspace.AllTycoons

function module.InitFolders()
	local function initTycoons(tycoonModel)
		local tycoonData = toolsModule.GetAllTools(tycoonModel,{Tycoons = true},true).Tycoons[1]
		tycoonData:Interface("Init",tycoonModel)
	end
	
	local function destroyTycoons(tycoonModel)
		local guidObject = toolsModule.GetGUIDObject(tycoonModel)
		if guidObject then guidObject:Destroy() end
	end

	for _, tycoonModel in ipairs(allTycoons:GetChildren()) do
		if not tycoonModel:IsDescendantOf(workspace) then continue end
		initTycoons(tycoonModel)
	end

	allTycoons.ChildAdded:Connect(initTycoons)
	allTycoons.ChildRemoved:Connect(destroyTycoons)

end

return module
