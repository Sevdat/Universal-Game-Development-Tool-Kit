local module = {}

local players = game:GetService("Players")

local cache = {}
local tempCache = {}

function module.UpdateTempCache()
	tempCache = table.clone(cache)

	for _, player in ipairs(players:GetPlayers()) do
		local playerData = player:FindFirstChild("PlayerData")
		local playerValues = playerData and playerData:FindFirstChild("Player")
		local robuxSpent = playerValues and playerValues:FindFirstChild("RobuxSpent")

		if robuxSpent then
			local found = false

			for _, entry in ipairs(tempCache) do
				if entry.UserId == player.UserId then
					entry.Name = player.Name
					entry.Amount = math.max(entry.Amount, robuxSpent.Value)
					found = true
					break
				end
			end

			if not found then
				table.insert(tempCache, {
					Name = player.Name,
					UserId = player.UserId,
					Amount = robuxSpent.Value,
				})
			end
		end
	end

	table.sort(tempCache, function(a, b)
		return a.Amount > b.Amount
	end)

	for i = #tempCache, 9, -1 do
		table.remove(tempCache, i)
	end

	cache = tempCache
	tempCache = {}
	
	return cache
end


return module
