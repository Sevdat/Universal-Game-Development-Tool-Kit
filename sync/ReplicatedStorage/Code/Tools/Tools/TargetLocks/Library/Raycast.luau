local module = {}

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local allRewards = workspace:FindFirstChild("AllRewards")
local localProjectiles = workspace:FindFirstChild("LocalProjectiles")
local spawnableRewards = workspace:FindFirstChild("SpawnableRewards")

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function module.GetRayResult(getPosition:boolean,getTargetModel:boolean,getToolTable:boolean)
	local camera = workspace.CurrentCamera
	if not camera then return end

	local origin = camera.CFrame.Position
	local direction = camera.CFrame.LookVector * 1000

	local result = workspace:Raycast(origin,direction,params)
	local position = getPosition and (result and result.Position or (origin+direction)) or nil
	local targetModel = getTargetModel and (result and result.Instance and result.Instance:FindFirstAncestorOfClass("Model")) or nil
	
	local toolTable = nil
	
	if getToolTable then
		local className, _, _ = targetModel and toolsModule.GetToolIdentifier(targetModel) or nil,nil,nil
		local canGet = className and (className == "NPCS" or className == "Players")
		
		toolTable = canGet and toolsModule.GetTool(targetModel) or nil
	end
	
	targetModel = toolTable and targetModel or nil
	
	return position,targetModel,toolTable
end

if isClient then
	local localPlayer = players.LocalPlayer

	local function OnCharacterAdded(character)
		task.wait()
		params.FilterDescendantsInstances = {character,allRewards,localProjectiles,spawnableRewards}
	end

	OnCharacterAdded(localPlayer.Character or localPlayer.CharacterAdded:Wait())
	localPlayer.CharacterAdded:Connect(OnCharacterAdded)
end

return module
