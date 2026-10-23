local module = {}

local isClient = game:GetService("RunService"):IsClient()
local items = require(script.Parent.Items)

module.BuyTool = script.BuyTool
module.SellTool = script.SellTool

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function module.ToolExists(player,toolPath)
	local character = player.Character
	local guidObject = character and character:FindFirstChild(toolPath)
	return guidObject
end

function module.FreeSlotsExists(player)
	local slot = {"Weapon1","Weapon2","Weapon3"}
	local isFree = false
	for i,slotName in ipairs(slot) do
		local data = toolsModule.GetData(player,{"Player",slotName})
		isFree = not isFree and data and data.Value == "" or isFree
	end
	
	return isFree
end

function module.Purchase(player,toolPath)
	if not module.FreeSlotsExists(player) then return false end
	
	local guidObject = module.ToolExists(player,toolPath)
	if guidObject then return false end
	
	local item = items[toolPath]
	local currency = item.Currency
	local price = item.Price
	
	local data = toolsModule.GetData(player,{"Player",currency})
	local amount = data and data.Value or 0
	if amount < price then return false end
	
	if not isClient then
		data.Value -= price
		toolsModule.CreateTool(toolPath,player.Character)
	end
	
	return true
end

function module.Sell(player,toolPath)
	local guidObject = module.ToolExists(player,toolPath)
	if not guidObject then return false end

	local item = items[toolPath]
	local currency = item.Currency
	local price = item.Price

	local data = toolsModule.GetData(player,{"Player",currency})
	
	if not isClient then
		guidObject:Destroy()
		data.Value += price
	end
	
	return true
end

if not isClient then
	module.BuyTool.OnServerEvent:Connect(function(player,toolPath)
		if toolPath ~= nil and typeof(toolPath) == "string" then
			module.Purchase(player,toolPath)
		end
	end)
	
	module.SellTool.OnServerEvent:Connect(function(player,toolPath)
		if toolPath ~= nil and typeof(toolPath) == "string" then
			module.Sell(player,toolPath)
		end
	end)
end

return module
