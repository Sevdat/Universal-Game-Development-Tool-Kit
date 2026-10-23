local module = {}

local cashReward = 13_000_000
local baseCashMultiplier = 1.5
local rebirthPrice = 67_000_000

function module.CalculateCash(rebirth)
	return cashReward + (cashReward * rebirth)
end

function module.CalculateCashMultiplier(rebirth)
	return baseCashMultiplier + (baseCashMultiplier * rebirth)
end

function module.RebirthPrice(rebirth)
	return rebirthPrice * (1.7 ^ (rebirth))
end

return module
