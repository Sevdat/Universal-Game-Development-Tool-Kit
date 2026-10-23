local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local isServer = game:GetService("RunService"):IsServer()

local allPlayers = workspace.AllPlayers

function module.InitFolders()

	local function onCharacterAdded(player, character)
		local playerData = player:WaitForChild("PlayerData")
		if isServer then
			character.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
			
			local guidObject = Instance.new("StringValue")
			guidObject.Name = "Players_Player_Default"

			local toolTable = toolsModule.CreateTool(guidObject)
			
			guidObject.Parent = character
			toolTable:Interface("Init",player)
			
			character.Parent = allPlayers
		else
			local child
			repeat
				task.wait(1)
				if not player.Parent or not character.Parent then return end
				child = character:FindFirstChild("Players_Player_Default")
			until child

			local allTools = toolsModule.GetAllTools(character,{Players = true},true)
			allTools.Players[1]:Interface("Init", player)
		end
	end

	local function onCharacterRemoving(player, character)
		local guidObject = toolsModule.GetGUIDObject(character)
		if guidObject then guidObject:Destroy() end
	end

	local function onPlayerAdded(player)
		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)

		player.CharacterRemoving:Connect(function(character)
			onCharacterRemoving(player, character)
		end)

		if player.Character then
			onCharacterAdded(player, player.Character)
		end
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
end

return module