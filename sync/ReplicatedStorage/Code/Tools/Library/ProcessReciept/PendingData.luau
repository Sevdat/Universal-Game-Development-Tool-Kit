local module = {}

local players = game:GetService("Players")
local marketplaceService = game:GetService("MarketplaceService")
local isClient = game:GetService("RunService"):IsClient()

module.PendingData = {}

function module.AddToPendingData(player:Players,productId:number,func: ()->())
	if isClient then
		local success, errorMessage = pcall(function()
			marketplaceService:PromptProductPurchase(player, productId)
		end)
	else
		module.PendingData[player.UserId] = function (insertProductId)
			if insertProductId == productId then
				return func()
			end
			return false
		end
	end
end

function module.GetFromPendingData(player)
	if isClient then return end

	return function(insertProductId)
		local pendingFunc = module.PendingData[player.UserId]
		module.PendingData[player.UserId] = nil
		return pendingFunc(insertProductId)
	end
end

local function onPlayerAdded(player)
	module.PendingData[player.UserId] = {}
end

local function onPlayerRemoving(player)
	module.PendingData[player.UserId] = nil
end

for _, player in ipairs(players:GetPlayers()) do
	onPlayerAdded(player)
end

players.PlayerAdded:Connect(onPlayerAdded)
players.PlayerRemoving:Connect(onPlayerRemoving)


return module
