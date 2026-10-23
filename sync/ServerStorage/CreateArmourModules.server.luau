local armour = game.ReplicatedStorage.Armours
local config = game.ReplicatedStorage.Code.Tools.Armours.RegularArmour.Config

local function rarityVariables(rarity)
	local income = 0
	local upgradePrice = 0
	local maxHealth = rarity == "Common" and 100 or rarity == "Rare" and 200 or rarity == "Epic" and 300 or rarity == "Mythic" and 400 or rarity == "Legendary" and 400 or 100
	local maxLevel = rarity == "Common" and 20 or rarity == "Rare" and 40 or rarity == "Epic" and 60 or rarity == "Mythic" and 80 or rarity == "Legendary" and 100 or 20
	local sell = 0

	if rarity == "Common" then
		income = math.random(1,10)
		upgradePrice = income*1.6
	end

	if rarity == "Rare" then
		income = math.random(20,30)
		upgradePrice = income*1.6
	end

	if rarity == "Epic" then
		income = math.random(45,80)
		upgradePrice = income*1.6
	end

	if rarity == "Mythic" then
		income = math.random(85,200)
		upgradePrice = income*1.6
	end

	if rarity == "Legendary" then
		income = math.random(200,400)
		upgradePrice = income*1.6
	end

	sell = income*2

	return math.round(income),math.round(upgradePrice),math.round(sell),maxLevel,maxHealth
end

local function createModule(armour,rarity)
	local module = Instance.new("ModuleScript")
	module.Name = armour.Name
	module.Parent = config

	armour:Clone().Parent = module

	local income,upgradePrice,sell,maxLevel,maxHealth =rarityVariables(rarity)

	module.Source = string.format( [[
return {
	ConfigName = script.Name,
	
	Name = script.Name,
	Armour = script[script.Name],
	
	Rarity = %q,
	Income = %d,
	UpgradePrice = %d,
	Sell = %d,
	
	MaxLevel = %d,
	MaxHealth = %d,
}
]],rarity,income,upgradePrice,sell,maxLevel,maxHealth)

end

for rarity,rarityFolder in ipairs(armour:GetChildren()) do
	for armour,armourModel in ipairs(rarityFolder:GetChildren()) do
		createModule(armourModel,rarityFolder.Name)
	end
end

