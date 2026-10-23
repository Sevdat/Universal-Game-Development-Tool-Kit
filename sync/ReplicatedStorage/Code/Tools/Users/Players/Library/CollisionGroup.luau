local module = {}

local function newCharacter(character)	
	for i,basepart in pairs(character:GetDescendants()) do
		if not basepart:IsA("BasePart") or basepart.Name == "HumanoidRootPart" then continue end
		basepart.CollisionGroup = "Player"
	end
	character.Parent = workspace.AllPlayers
end

local function newPlayer(player)
	if player.Character then
		task.defer(newCharacter, player.Character)
	end
	player.CharacterAdded:Connect(newCharacter)
end

for _, player in game.Players:GetPlayers() do
	task.defer(newPlayer, player)
end

game.Players.PlayerAdded:Connect(newPlayer)

return module
