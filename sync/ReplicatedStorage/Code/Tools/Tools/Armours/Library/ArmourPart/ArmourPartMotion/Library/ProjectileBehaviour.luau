local module = {}

local runService = game:GetService("RunService")

local localProjectiles = workspace:WaitForChild("LocalProjectiles")
local allZones = workspace:FindFirstChild("AllZones")
local allNPC = workspace:FindFirstChild("AllNPC")

local isServer = runService:IsServer()

module.params = RaycastParams.new()
module.params.FilterType = Enum.RaycastFilterType.Include
module.params.FilterDescendantsInstances = {workspace.AllPlayers}

function module.IsFiniteVector3(v: Vector3): boolean
	local check = math.isfinite(v.X) and math.isfinite(v.Y) and math.isfinite(v.Z)
	return check
end

return module
