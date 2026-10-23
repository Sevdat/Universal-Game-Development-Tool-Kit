local pendingData = require(script.Parent.PendingData)

local ids = {
	stealID = 3585698172,

	starterPack = 3718415795,

	cash100K = 3718399363,
	cash500K = 3718399873,
	cash2M = 3718400086,
	cash20M = 3718400286,
	cash500M = 3718400414, 
	cash1B = 3718400539,
	
	EpicLuckyBlock = 3718491159,
	MythicLuckyBlock = 3718494954,
	LegendaryLuckyBlock = 3718495178,
	
	donation1M = 3718401095
}

local productFunctions = {}

for _,productId in pairs(ids) do
	productFunctions[productId] = function(receipt, player)
		local func = pendingData.GetFromPendingData(player)
		if func then func(productId) end
		return true
	end
end

return productFunctions