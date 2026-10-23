local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")
local isClient = game:GetService("RunService"):IsClient()

local damageIndicator = require(script.DamageIndicator)
local spatialSounds = require(script.SpatialSounds)

local safeZone = require(script.SafeZone)

function module.Result(weaponTable,result:RaycastResult)
	local killed = false

	local hit = result.Instance
	local position = result.Position
	
	local isInSafeZone = safeZone.IsPositionInsidePart(position)
	local radius = weaponTable:GetVariable("Radius") or 0
	local damage = isInSafeZone and 0 or weaponTable:GetDamage(result)
	
	if radius >0 then
		local npcHitboxes, humanoidRootParts = module.GetHitInArea(position,radius)
		local character = weaponTable:GetVariable("Character")
		
		local anyNPCKilled = module.LoopedDamage(damage, npcHitboxes,character)
		local anyPlayerKilled = module.LoopedDamage(damage, humanoidRootParts,character)
		killed = anyNPCKilled or anyPlayerKilled
	else
		local className,toolTable = module.GetHitData(hit)
		if not className or not toolTable then return end

		killed = module.Damage(className,toolTable,hit,damage)
	end
	
	if isClient then
		local sound = killed and weaponTable.KillSound or weaponTable.HitSound
		spatialSounds.Play3DSound(sound,hit)
	end
	
	if killed then
		local character = weaponTable.Character
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = humanoid.MaxHealth 
		end
	end
	
	return killed
end

function module.GetHitInArea(position,radius)
	
	local serverModelParams = OverlapParams.new()
	serverModelParams.FilterType = Enum.RaycastFilterType.Include
	serverModelParams.FilterDescendantsInstances = {workspace.AllNPC.ServerModels}

	local hrpParams = OverlapParams.new()
	hrpParams.FilterType = Enum.RaycastFilterType.Include
	hrpParams.FilterDescendantsInstances = {workspace.AllPlayers}
	hrpParams.CollisionGroup = "Player"
	
	local npcHitboxes = workspace:GetPartBoundsInRadius(position,radius, serverModelParams)
	local humanoidRootParts = workspace:GetPartBoundsInRadius(position, radius, hrpParams)

	for i = #humanoidRootParts, 1, -1 do
		if humanoidRootParts[i].Name ~= "HumanoidRootPart" then
			table.remove(humanoidRootParts, i)
		end
	end
	
	return npcHitboxes, humanoidRootParts
end

function module.LoopedDamage(damage, hitTable,shooterCharacter:Model)
	local killed = false
	local shooterIsPlayer = shooterCharacter and players:GetPlayerFromCharacter(shooterCharacter)
	
	for _, hit in hitTable do
		local className,toolTable = module.GetHitData(hit)
		
		if not toolTable or toolTable.Character == shooterCharacter 
			or not shooterIsPlayer and className == "NPCS" then continue end
		
		local checkKilled = module.Damage(className,toolTable,hit,damage)
		killed = killed or checkKilled
	end
	return killed
end

function module.GetHitData(part)
	local model = part:FindFirstAncestorOfClass("Model")
	
	local toolTable = model and toolsModule.GetTool(model)
	local guidObject = toolTable and toolTable.GUIDObject
	if not guidObject then return nil,nil end

	local className,_,_ = toolsModule.GetToolIdentifier(guidObject)

	return className,toolTable
end

function module.Damage(className,toolTable,hit,damage)
	if not isClient then 
		local damageType = (className == "NPCS" and "DamageNPC") or (className == "Players" and "DamagePlayer")
		
		if not damageType or not toolTable then return end
		
		local killed = toolTable:Interface(damageType,damage)
		
		return killed
	else
		damageIndicator.ShowDamage(hit.CFrame, damage)
	end
end

return module
