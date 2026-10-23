local module = {}

local isClient = game:GetService("RunService"):IsClient()

local remote = require(script.Remote)
local calculations = require(script.Calculations)
local suffix = require(script.Suffix)

if not isClient then return module end

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local tween = require(script.Parent.Parent.Library.Tween)

local gui = isClient and game.Players.LocalPlayer:FindFirstChild("PlayerGui") or nil
local screenGUI = gui and gui:FindFirstChild("ScreenGui")
local allMenu = screenGUI and screenGUI:FindFirstChild("AllMenu")
local rebirthMenu = allMenu and allMenu:FindFirstChild("Rebirth")

local center = rebirthMenu and rebirthMenu:FindFirstChild("Center"):FindFirstChild("StudImage")
local rewards = center and center:FindFirstChild("Rewards")

local bar = center and center:FindFirstChild("Bar"):FindFirstChild("UIGradient")
local barTextLabel = center and center:FindFirstChild("Bar"):FindFirstChild("TextLabel")

local cash = rewards and rewards:FindFirstChild("Cash"):FindFirstChild("Recieve")
local multi = rewards and rewards:FindFirstChild("Multi"):FindFirstChild("Recieve")
local rebirthButton = rebirthMenu and tween.Button(rebirthMenu.RebirthButton)

local playerCash = toolsModule.GetData(game.Players.LocalPlayer,{"Player","Cash"})
local playerCashMultiplier = toolsModule.GetData(game.Players.LocalPlayer,{"Player","CashMultiplier"})
local playerRebirth = toolsModule.GetData(game.Players.LocalPlayer,{"Player","Rebirth"})

function module.Update(newValue)
	local currentCash = newValue or playerCash.Value
	local cashReward = calculations.CalculateCash(playerRebirth.Value)
	local rebirthPrice = calculations.RebirthPrice(playerRebirth.Value)
	bar.Offset = Vector2.new(math.clamp(currentCash/rebirthPrice,0,1),0)
	cash.Text = suffix.Shorten(cashReward)
	multi.Text = "x"..calculations.CalculateCashMultiplier(playerRebirth.Value)
	barTextLabel.Text = "$"..suffix.Shorten(currentCash).."/"..suffix.Shorten(rebirthPrice)
end

module.Update()
playerCash.Changed:Connect(function(newValue)
	module.Update(newValue)
end)

rebirthButton.Activated:Connect(function(player)
	remote.Activate(game.Players.LocalPlayer)
end)

return module