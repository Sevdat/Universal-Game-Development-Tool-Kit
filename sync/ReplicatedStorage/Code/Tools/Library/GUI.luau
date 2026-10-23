local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]
local isClient = game:GetService("RunService"):IsClient()

local visual = require(script.Library.Visual)

toolsModule.AddToPostInit(function()
	require(script.AllMenu)
	if isClient then
		require(script.LeftButtons)
		visual.Init()
		require(script.Rewards)
		require(script.LoadScreen)
		require(script.Statbar)
	end
end)

return module
