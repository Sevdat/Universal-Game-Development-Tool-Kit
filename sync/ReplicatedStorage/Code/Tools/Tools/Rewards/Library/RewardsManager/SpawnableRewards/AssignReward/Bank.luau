local module = {}

local players = game:GetService("Players")

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

module.Bank = {}

function module.Bank:OweRewardToPlayer(player,guidObject,amount)
	local data = self[player.UserId]

	if not data then return end

	data[guidObject.Name] = math.clamp((data[guidObject.Name] or 0) + amount,0,math.huge)
	
	return data[guidObject.Name] or 0
end

function module.Bank:GiveRewardToPlayer(player,guidObject,amount)
	local data = self[player.UserId]
	
	if not data or not data[guidObject.Name] then return 0 end
	
	local amountInBank = data[guidObject.Name]
	local returnAmount = amountInBank-amount >=0 and amount or amountInBank

	data[guidObject.Name] = math.clamp(amountInBank-amount,0,math.huge)
	
	local _,behaviourName,configName = toolsModule.GetToolIdentifier(guidObject)
	
	if behaviourName == "Armour" then
		toolsModule.UpdateFreeTycoonData(player,"Armours_RegularArmour_"..configName)
	elseif behaviourName == "Cash" then
		local cashMultiplier = toolsModule.GetData(player,{"Player","CashMultiplier"})
		local multiplier = cashMultiplier and cashMultiplier.Value or 1
		toolsModule.UpdateData(player,{"Player",behaviourName},returnAmount*multiplier,true)
	else
		toolsModule.UpdateData(player,{"Player",behaviourName},returnAmount,true)
	end
end


local function onPlayerAdded(player)
	module.Bank[player.UserId] = {}
end

local function onPlayerRemoving(player)
	module.Bank[player.UserId] = nil
end

for _, player in ipairs(players:GetPlayers()) do
	onPlayerAdded(player)
end

players.PlayerAdded:Connect(onPlayerAdded)
players.PlayerRemoving:Connect(onPlayerRemoving)


return module
