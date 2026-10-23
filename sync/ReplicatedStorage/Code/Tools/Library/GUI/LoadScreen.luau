local module = {}

local isClient = game:GetService("RunService"):IsClient()

if not isClient then return module end

local gui = isClient and game.Players.LocalPlayer:FindFirstChild("PlayerGui") or nil
local screenGUI = gui and gui:FindFirstChild("ScreenGui")
local loadScreen = screenGUI and screenGUI:FindFirstChild("LoadScreen")

local starterGUI = game:GetService("StarterGui")
starterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false)

loadScreen.Visible = false

return module
