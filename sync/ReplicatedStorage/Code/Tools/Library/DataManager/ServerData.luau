local module = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if RunService:IsClient() then return module end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")

local Template = require(script.Template)
local ProfileStore = require(script.ProfileStore)
local dataStoreName = RunService:IsStudio() and "Test3" or "Live"
local PlayerStore = ProfileStore.New(dataStoreName, Template)

local syncData = require(script.SyncData)
local assignTycoon = require(script.AssignTycoon)

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

module.Data = {}

local function PlayerAdded(player: Player)	
	local profile = PlayerStore:StartSessionAsync("Player_" .. player.UserId, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			module.Data[player] = nil
			player:Kick("Data error occured. Please rejoin.")
		end)

		if player.Parent == Players then
			module.Data[player] = profile
		else
			profile:EndSession()
		end
	else
		player:Kick("Data error occured. Please rejoin.")
	end
	
	syncData.Load(player,profile)
	
	assignTycoon:AddPlayer(player)
	
end

toolsModule.AddToPostInit(function()
	for _, player in Players:GetPlayers() do
		task.spawn(PlayerAdded, player)
	end

	Players.PlayerAdded:Connect(PlayerAdded)

	Players.PlayerRemoving:Connect(function(player)
		assignTycoon:RemovePlayer(player)

		local profile = module.Data[player]

		syncData.Save(player,profile)

		profile:EndSession()
		module.Data[player] = nil
	end)
end)

return module

--local function Initialize(player: Player, profile: typeof(PlayerStore:StartSessionAsync()))
--	local leaderstats = Instance.new("Folder", player)
--	leaderstats.Name = "leaderstats"

--	local kills = Instance.new("IntValue", leaderstats)
--	kills.Name = "Kills"
--	kills.Value = profile.Data.Kills

--	local cash = Instance.new("IntValue", leaderstats)
--	cash.Name = "Cash"
--	cash.Value = profile.Data.Cash

--	local values = Instance.new("Folder", player)
--	values.Name = "Values"

--	local uncollectedCash = Instance.new("IntValue", values)
--	uncollectedCash.Name = "UncollectedCash"

--	local damageMultiplier = Instance.new("IntValue", values)
--	damageMultiplier.Name = "DamageMultiplier"
--end


--local function WipePlayerData(userId:IntValue)
--	local profileKey = "Player_" .. userId

--	local player = Players:GetPlayerByUserId(userId)
--	if player and module.Data[player] then
--		module.Data[player]:Release()
--		module.Data[player] = nil
--	end

--	local dataStore = DataStoreService:GetDataStore(dataStoreName)

--	local success, result = pcall(function()
--		return dataStore:RemoveAsync(profileKey)
--	end)

--	if success then
--		print("Successfully wiped data for user ID:", userId)
--		return true
--	else
--		warn("Failed to wipe data for user ID:", userId, "Error:", result)
--		return false
--	end
--end