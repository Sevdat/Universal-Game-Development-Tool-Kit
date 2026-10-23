local module = {}

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local isClient = runService:IsClient()
local isStudio = runService:IsStudio()

local localPlayer = isClient and players.LocalPlayer

local collectionRadius = 90
local collectionDistance = 7

local CHECK_INTERVAL = 0.1
local timeAccumulator = 0

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = {workspace.AllRewards.Vacuum} 

function module.SetSquareSize(part)
	local size = collectionRadius * math.sqrt(2)
	part.Size = Vector3.new(size,size,size)
	part.Transparency = isStudio and 0.7 or 1
end


function module.Vacumm(dt)
	if not isClient then return end
	
	timeAccumulator += dt
	if timeAccumulator <= CHECK_INTERVAL then return end

	timeAccumulator = 0

	local character = localPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")

	if not hrp then return end

	local hrpPosition = hrp.Position
	local partsInRange = workspace:GetPartBoundsInRadius(hrpPosition, collectionRadius, overlapParams)

	for _, part in ipairs(partsInRange) do
		if part:IsA("BasePart") then
			local alignPosition = part:FindFirstChild("AlignPosition")
			if alignPosition and not alignPosition.Enabled then
				alignPosition.ApplyAtCenterOfMass = true
				part.CanCollide = false
				alignPosition.Attachment1 = hrp:FindFirstChild("RootAttachment")
				part.Anchored = false
				alignPosition.Enabled = true
			end

			local distance = (hrpPosition - part.Position).Magnitude

			if distance < collectionDistance then
				local model = part.Parent
				if model then 
					model:Destroy() 
				end
			end

		end
	end
end


return module
