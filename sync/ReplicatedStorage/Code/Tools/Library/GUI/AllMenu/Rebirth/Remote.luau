local module = {}

local isClient = game:GetService("RunService"):IsClient()
local calculations = require(script.Parent.Calculations)

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

module.RebirthRemote = script.Rebirth

function module.Activate(player)	
	local cash = toolsModule.GetData(player,{"Player","Cash"})
	local cashMultiplier = toolsModule.GetData(player,{"Player","CashMultiplier"})
	local rebirth = toolsModule.GetData(player,{"Player","Rebirth"})
	local ownedTycoon = toolsModule.GetData(player,{"Tycoon","OwnedTycoon"})

	if cash.Value < calculations.RebirthPrice(rebirth.Value) then return end
	
	if isClient then
		module.RebirthRemote:FireServer()
	else
		cash.Value = calculations.CalculateCash(rebirth.Value)
		cashMultiplier.Value = calculations.CalculateCashMultiplier(rebirth.Value)
		rebirth.Value += 1

		local tycoonTable = toolsModule.GetTool(ownedTycoon.Value)
		tycoonTable:Rebirth()
	end
end

if not isClient then
	module.RebirthRemote.OnServerEvent:Connect(function(player)
		module.Activate(player)
	end)
end

return module
