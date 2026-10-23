local module = {}

local armourRarity = require(script.ArmourRarity)

local legendarySpawned = false
local mythicSpawned = false

local color = {
	Common = Color3.fromRGB(0, 134, 0),
	Rare = Color3.fromRGB(82, 124, 174),
	Epic = Color3.fromRGB(123, 47, 123),
	Mythic = Color3.fromRGB(196, 40, 28),
	Legendary = Color3.fromRGB(255, 176, 0)
}


function module.RollWinReward()
	local rarity,color = module.GetRarity()
	local armourName = armourRarity.Rarity[rarity][math.random(1,#armourRarity.Rarity[rarity])]
	return armourName,color or Color3.fromRGB(255,255,255)
end

function module.GetRarity()
	local rarity = getLegendary() or getMythic()
	local chance = math.random(0,99)/100
	if not rarity then
		rarity = chance<0.2 and "Epic" or chance<0.4 and "Rare" or "Common"
	end

	return rarity,color[rarity]
end

function getLegendary()
	local now = DateTime.now():ToUniversalTime()

	local minute = now.Minute

	local isInInterval = (minute == 0 or minute == 30)
	
	if not legendarySpawned and isInInterval then
		legendarySpawned = true
		return "Legendary"
	elseif not isInInterval then
		legendarySpawned = false
		return false
	end
end

function getMythic()
	local now = DateTime.now():ToUniversalTime()

	local minute = now.Minute

	local isInInterval = (minute == 0 or minute == 15 or minute == 45)

	if not mythicSpawned and isInInterval then
		mythicSpawned = true
		return "Mythic"
	elseif not isInInterval then
		mythicSpawned = false
		return false
	end
end

return module
