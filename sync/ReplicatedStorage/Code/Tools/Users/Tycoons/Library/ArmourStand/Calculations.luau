local module = {}

function module.CalculateIncome(income,level)
	return income * (1.4 ^ (level - 1))
end

function module.CalculateUpgradePrice(upgradePrice,level)
	return upgradePrice * (1.7 ^ (level - 1))
end

function module.CalculateSell(sell,level)
	return sell * (1.2 ^ (level - 1))
end

function module.GetMoneySince(lastTimestamp, income, level,incomeMultiplier)
	local now = os.time()
	local secondsPassed = now - lastTimestamp
	return secondsPassed* module.CalculateIncome(income,level)*incomeMultiplier
end


return module
