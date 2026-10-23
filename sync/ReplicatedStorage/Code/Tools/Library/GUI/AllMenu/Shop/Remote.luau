local module = {}

local isClient = game:GetService("RunService"):IsClient()

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local helperFunctions = require(script.HelperFunctions)

module.RequestDeveloperProduct = script.RequestDeveloperProduct

module.ProductFunctions = {
	StarterPack = function(player)
		toolsModule.StarterPackPrompt(player,function()
			helperFunctions.GiveArmour(player,"Armours_RegularArmour_Talpa Di Fero")
			task.wait(1)
			helperFunctions.GiveArmour(player,"Armours_RegularArmour_Chef Crabracadabra")
			toolsModule.UpdateData(player,{"Player","Cash"},200_000,true)
		end)
	end,
	
	Cash100K = function(player)
		toolsModule.CashPrompt(player,100_000,function()
			toolsModule.UpdateData(player,{"Player","Cash"},100_000,true)
		end)
	end,
	Cash500K = function(player)
		toolsModule.CashPrompt(player,500_000,function()
			toolsModule.UpdateData(player,{"Player","Cash"},500_000,true)
		end)
	end,
	Cash2M = function(player)
		toolsModule.CashPrompt(player,2_000_000,function()
			toolsModule.UpdateData(player,{"Player","Cash"},2_000_000,true)
		end)
	end,
	Cash20M = function(player)
		toolsModule.CashPrompt(player,20_000_000,function()
			toolsModule.UpdateData(player,{"Player","Cash"},20_000_000,true)
		end)
	end,
	Cash500M = function(player)
		toolsModule.CashPrompt(player,500_000_000,function()
			toolsModule.UpdateData(player,{"Player","Cash"},500_000_000,true)
		end)
	end,
	Cash1B = function(player)
		toolsModule.CashPrompt(player,1_000_000_000,function()
			toolsModule.UpdateData(player,{"Player","Cash"},1_000_000_000,true)
		end)
	end,
	
	
	EpicLuckyBlock = function(player)
		toolsModule.LuckyBlockPrompt(player,"Epic",function()
			local chance = math.random(0,100)

			if chance >= 90 then
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Gangster Footera")
			elseif chance >= 80 then
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Lirilì Larilà")
			elseif chance >= 70 then
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Trippi Troppi")
			else
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Talpa Di Fero")
			end
		end)
	end,
	MythicLuckyBlock = function(player)
		toolsModule.LuckyBlockPrompt(player,"Mythic",function()
			local chance = math.random(0,100)

			if chance >= 90 then
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Tim Cheese")
			elseif chance >= 80 then
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Tung Tung Tung Sahur")
			elseif chance >= 70 then
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Orangutini Ananassini")
			else
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Chef Crabracadabra")
			end
		end)
	end,
	LegendaryLuckyBlock = function(player)
		toolsModule.LuckyBlockPrompt(player,"Legendary",function()
			local chance = math.random(0,100)

			if chance >= 90 then
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Cocofanto Elefanto")
			elseif chance >= 80 then
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_La Vacca Saturno Saturnita")
			elseif chance >= 70 then
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Brri Brri Bicus Dicus Bombicus")
			else
				helperFunctions.GiveArmour(player,"Armours_RegularArmour_Graipuss Medussi")
			end
		end)
	end,
	
	
	Donate = function(player)
		toolsModule.DonationPrompt(player,1_000_000,function()

		end)
	end,
}

module.PurchaseGrantable = {
	StarterPack = function(player)
		return toolsModule.AmountOfFreeTycoonSlots(player)>=2
	end,
	
	EpicLuckyBlock = function(player)
		return toolsModule.AmountOfFreeTycoonSlots(player)>=1
	end,
	MythicLuckyBlock = function(player)
		return toolsModule.AmountOfFreeTycoonSlots(player)>=1
	end,
	LegendaryLuckyBlock = function(player)
		return toolsModule.AmountOfFreeTycoonSlots(player)>=1
	end
}

function module.Activate(player,productName)
	local productFunction = module.ProductFunctions[productName]
	
	if productFunction then
		if isClient then
			local purchaseGrantable = module.PurchaseGrantable[productName]
			if purchaseGrantable and not purchaseGrantable(game.Players.LocalPlayer) then return end
			
			module.RequestDeveloperProduct:FireServer(productName)
		end
		productFunction(player)
	end
end

if not isClient then
	module.RequestDeveloperProduct.OnServerEvent:Connect(function(player,productName)
		module.Activate(player,productName)
	end)
end

return module
