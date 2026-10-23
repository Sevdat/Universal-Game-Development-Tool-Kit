local module = {}

local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local lighting = game:GetService("Lighting")

local allPlanets = workspace:FindFirstChild("AllPlanets")
local earth = allPlanets:FindFirstChild("Earth")

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local count = 0
local currentSkyboxName = nil

local function IsInsideSphere(model, position)
	local part = model:FindFirstChildOfClass("Part")
	if not part then return false end

	local mesh = part:FindFirstChildOfClass("SpecialMesh")
	local scale = mesh and mesh.Scale or Vector3.one
	local radius = part.Size * scale

	local radiusFromCenter = (position - part.Position).Magnitude
	
	return radiusFromCenter <= math.min(radius.X, radius.Y, radius.Z)
end

local function updateSkybox(dt)
	count += dt
	if count < 0.1 then return end
	count = 0
	
	local player = game.Players.LocalPlayer
	local character = player and player.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	local skyboxName = nil
	
	for i,model in ipairs(allPlanets:GetChildren()) do
		if IsInsideSphere(model, humanoidRootPart.Position) then
			skyboxName = model.Name
			break
		end
	end
	
	skyboxName = skyboxName or "Space"

	if skyboxName == currentSkyboxName then return end
	currentSkyboxName = skyboxName
	
	local skyBox = currentSkyboxName and script:FindFirstChild(currentSkyboxName)
	
	if skyBox then
		for i,instance in ipairs(lighting:GetChildren()) do
			instance:Destroy()
		end
		
		for i,instance in ipairs(skyBox:GetChildren()) do
			local clone = instance:Clone()
			clone.Parent = lighting
		end
	end
end

toolsModule.AddToPostInit(function()
	if isClient then
		toolsModule.AddToLoop("Heartbeat",updateSkybox)
	end
end)

return module
