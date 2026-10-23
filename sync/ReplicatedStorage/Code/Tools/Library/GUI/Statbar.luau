local module = {}

local isClient = game:GetService("RunService"):IsClient()

if not isClient then return module end

local starterGUI = game:GetService("StarterGui")
local players = game:GetService("Players")

starterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.Health,false)

local gui = isClient and game.Players.LocalPlayer:FindFirstChild("PlayerGui") or nil
local screenGUI = gui and gui:FindFirstChild("ScreenGui")
local statbar = screenGUI and screenGUI:FindFirstChild("StatBar")
local health = statbar and statbar:FindFirstChild("Health"):FindFirstChild("Bar")

local function OnCharacterAdded(character)
	task.wait(0.1)
	character.Humanoid.HealthChanged:Connect(function(currentHealth)
		health.Size = UDim2.new(currentHealth / character.Humanoid.MaxHealth, 0, 1, 0)
	end)
end

local localPlayer = players.LocalPlayer
OnCharacterAdded(localPlayer.Character or localPlayer.CharacterAdded:Wait())
localPlayer.CharacterAdded:Connect(OnCharacterAdded)


return module
