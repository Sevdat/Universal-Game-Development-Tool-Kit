local module = {}

local players = game:GetService("Players")
local isClient = game:GetService("RunService"):IsClient()

local tween = require(script.Tween)
local suffix = require(script.Suffix)

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local gui = isClient and game.Players.LocalPlayer:FindFirstChild("PlayerGui") or nil
local screenGUI = gui and gui:FindFirstChild("ScreenGui")
local rewards = screenGUI and screenGUI:FindFirstChild("Rewards")
local tween = require(script.Tween)

local tweens = {}

if isClient then	
	for i,child in ipairs(rewards:GetChildren()) do
		if child:IsA("Frame") then
			local data = toolsModule.GetData(players.LocalPlayer,{"Player",child.Name})
			table.insert(tweens,tween.new(child,data))
		end
	end
end



return module
