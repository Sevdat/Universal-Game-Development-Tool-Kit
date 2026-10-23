local module = {}

local isClient = game:GetService("RunService"):IsClient()

local players = game:GetService("Players")
local collectionService = game:GetService("CollectionService")
local easyVisuals = require(script:FindFirstChild("EasyVisuals"))

local visuals = {
	EasyVisuals_Rainbow = function(uiInstance: GuiObject)
		easyVisuals.new(uiInstance,"Rainbow",0.35)
	end,
}


function module.Init()
	if not isClient then return end
	
	local playerGUI = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
	for tagName,func in pairs(visuals) do
		local tags = collectionService:GetTagged(tagName)
		
		for _,uiInstance in ipairs(tags) do
			if uiInstance:IsDescendantOf(playerGUI) then
				func(uiInstance)
			end
		end
	end
end


return module
