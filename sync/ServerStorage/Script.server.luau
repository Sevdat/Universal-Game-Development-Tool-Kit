local isStudio = game:GetService("RunService"):IsStudio()

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local DonationsStore = DataStoreService:GetDataStore(isStudio and "TestRobuxSpent" or "RobuxSpent")

local MAX_ENTRIES = 10

while true do
	local success, topDonators = pcall(function()
		return DonationsStore:GetAsync("TopDonators") or {}
	end)

	if success then
		for _, player in ipairs(Players:GetPlayers()) do
			local robuxSpent = player:FindFirstChild("PlayerData")
				and player.PlayerData:FindFirstChild("Player")
				and player.PlayerData.Player:FindFirstChild("RobuxSpent")

			if robuxSpent and robuxSpent.Value > 0 then
				local found = false

				for _, entry in ipairs(topDonators) do
					if entry.UserId == player.UserId then
						entry.Amount = math.max(entry.Amount, robuxSpent.Value)
						found = true
						break
					end
				end

				if not found then
					table.insert(topDonators, {
						UserId = player.UserId,
						Amount = robuxSpent.Value,
					})
				end
			end
		end

		table.sort(topDonators, function(a, b)
			return a.Amount > b.Amount
		end)

		while #topDonators > MAX_ENTRIES do
			table.remove(topDonators)
		end

		local saveSuccess, err = pcall(function()
			DonationsStore:SetAsync("TopDonators", topDonators)
		end)

		if not saveSuccess then
			warn("Failed to save leaderboard:", err)
		end

		for rank, entry in ipairs(topDonators) do
			local nameSuccess, name = pcall(function()
				return Players:GetNameFromUserIdAsync(entry.UserId)
			end)

			print(rank, nameSuccess and name or tostring(entry.UserId), entry.Amount)
		end
	else
		warn("Failed to load leaderboard:", topDonators)
	end

	task.wait(10)
end