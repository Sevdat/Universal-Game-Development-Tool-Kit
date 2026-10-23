local module = {}

local players = game:GetService("Players")
local runService = game:GetService("RunService")

local localProjectiles = workspace:WaitForChild("LocalProjectiles")
local allPlayers = workspace.AllPlayers
local allNPC = workspace.AllNPC

local isServer = runService:IsServer()

function module.IsFiniteVector3(v: Vector3): boolean
	local check = math.isfinite(v.X) and math.isfinite(v.Y) and math.isfinite(v.Z)
	return check
end

function module.CreateBehaviour(character,projectile)	
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	if projectile then
		projectile.Parent = localProjectiles
		projectile.Anchored = true
	end
	
	local isPlayer = character and players:GetPlayerFromCharacter(character)
	
	params.FilterDescendantsInstances = 
		isPlayer and { character, allNPC.ClientModels, localProjectiles, projectile, workspace.SpawnableRewards }
		or { character, allNPC, localProjectiles, projectile, workspace.SpawnableRewards }

	return params
end

return module
