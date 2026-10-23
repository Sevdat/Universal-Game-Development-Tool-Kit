local module = {}

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local isClient = game:GetService("RunService"):IsClient()

local productFunctions = require(script.ProductFunctions)
local pendingData = require(script.PendingData)

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function module.AddToPendingData(player:Players,productId:number,func:()->())
	pendingData.AddToPendingData(player,productId,func)
end

if not isClient then
	local function processReceipt(receiptInfo)
		local userId = receiptInfo.PlayerId
		local productId = receiptInfo.ProductId

		local player = Players:GetPlayerByUserId(userId)
		if player then
			local handler = productFunctions[productId]

			local success, result = pcall(handler, receiptInfo, player)
			if success then
				toolsModule.UpdateData(player,{"Player","RobuxSpent"},receiptInfo.CurrencySpent or 0,true)
				return Enum.ProductPurchaseDecision.PurchaseGranted
			else
				warn("Failed to process receipt:", receiptInfo, result)
			end
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	MarketplaceService.ProcessReceipt = processReceipt
end

return module