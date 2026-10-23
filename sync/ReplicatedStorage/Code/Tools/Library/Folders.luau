local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local isServer = game:GetService("RunService"):IsServer()

if isServer then
	for i,e in ipairs(script.Folders:GetChildren()) do
		e.Parent = workspace
	end
end

function module.InitFolders()
	local allFolders = {
		require(script.AllRewards),
		require(script.LocalProjectiles),
		require(script.AllNPC), 
		require(script.AllPlayers),
		require(script.Tycoons),
		require(script.AllMissionZones),
	}
	
	for i,e in ipairs(allFolders) do
		e.InitFolders(toolsModule)
	end
end

return module
