local module = {}

local isClient = game:GetService("RunService"):IsClient()
local remote = require(script.Remote)

if not isClient then return module end

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local tween = require(script.Parent.Parent.Library.Tween)

local gui = isClient and game.Players.LocalPlayer:FindFirstChild("PlayerGui") or nil
local screenGUI = gui and gui:FindFirstChild("ScreenGui")
local allMenu = screenGUI and screenGUI:FindFirstChild("AllMenu")

local indexMenu = allMenu and allMenu:FindFirstChild("Shop")
local scrollingFrame = indexMenu and indexMenu.ScrollingFrame

local starterPack = scrollingFrame and scrollingFrame.StarterPack
local starterPackButton = starterPack and tween.Button(starterPack.ImageButton)

local cashes = scrollingFrame and scrollingFrame.Cashes
local cashes1 = scrollingFrame and scrollingFrame.Cashes1
local cash100KButton = cashes and tween.Button(cashes.Cash100K)
local cash500KButton = cashes and tween.Button(cashes.Cash500K)
local cash2MButton = cashes and tween.Button(cashes.Cash2M)
local cash20MButton = cashes1 and tween.Button(cashes1.Cash20M)
local cash500MButton = cashes1 and tween.Button(cashes1.Cash500M)
local cash1BButton = cashes1 and tween.Button(cashes1.Cash1B)

local luckyBlocks = scrollingFrame and scrollingFrame.LuckyBlocks
local epicLuckyBlockButton = luckyBlocks and tween.Button(luckyBlocks.EpicLuckyBlock)
local mythicLuckyBlockButton = luckyBlocks and tween.Button(luckyBlocks.MythicLuckyBlock)
local legendaryLuckyBlockButton = luckyBlocks and tween.Button(luckyBlocks.LegendaryLuckyBlock)

local donate = scrollingFrame and scrollingFrame.Donate
local donateButton = donate and tween.Button(donate.ImageButton)


starterPackButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"StarterPack")
end)


cash100KButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"Cash100K")
end)
cash500KButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"Cash500K")
end)
cash2MButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"Cash2M")
end)
cash20MButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"Cash20M")
end)
cash500MButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"Cash500M")
end)
cash1BButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"Cash1B")
end)


epicLuckyBlockButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"EpicLuckyBlock")
end)
mythicLuckyBlockButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"MythicLuckyBlock")
end)
legendaryLuckyBlockButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"LegendaryLuckyBlock")
end)


donateButton.Activated:Connect(function()
	remote.Activate(game.Players.LocalPlayer,"Donate")
end)


return module