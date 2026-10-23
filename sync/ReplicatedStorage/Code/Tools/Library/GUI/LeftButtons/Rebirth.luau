local module = {}

local gui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
local screenGUI = gui:FindFirstChild("ScreenGui")
local allMenu = screenGUI:FindFirstChild("AllMenu")
local tween = require(script.Parent.Library.Tween)

local leftButtons = screenGUI:FindFirstChild("LeftButtons")

module.Menu = allMenu:FindFirstChild("Rebirth")
module.Open = tween.Button(leftButtons:FindFirstChild("Rebirth"))
module.Close = tween.Button(module.Menu:FindFirstChild("Close"))

return module