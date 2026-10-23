local module = {}

local isClient = game:GetService("RunService"):IsClient()
local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local gui = isClient and game.Players.LocalPlayer:FindFirstChild("PlayerGui") or nil
local screenGUI = gui and gui:FindFirstChild("ScreenGui")
local allMenu = screenGUI and screenGUI:FindFirstChild("AllMenu")

local scrollingFrame = allMenu and allMenu:FindFirstChild("Index").ScrollingFrame

local rarityColor = require(script.RarityColor)

local alltoolPaths = toolsModule.GetAllToolPaths()

local order = {
	Common = 1,
	Rare = 2,
	Epic = 3,
	Mythic = 4,
	Legendary = 5
}

function createIndex(toolPath)
	local config = toolsModule.GetConfig(toolPath)
	if not config then return end
	
	local rarity = config.Rarity
	local color = rarityColor[rarity] or Color3.fromRGB(255,255,255)
	
	local cloneTemplate = scrollingFrame[rarity]:Clone()
	local studImage = cloneTemplate:FindFirstChild("StudImage")
	local viewportFrame = studImage:FindFirstChild("ViewportFrame")
	local worldModel = viewportFrame:FindFirstChild("WorldModel")
	local camera = viewportFrame:FindFirstChild("Camera")
	
	cloneTemplate.LayoutOrder = order[rarity] or 0
	studImage.NameLabel.Text = config.ConfigName
	studImage.RarityLabel.Text = rarity
	studImage.RarityLabel.TextColor3 = color

	cloneTemplate.Name = toolPath
	cloneTemplate.Parent = scrollingFrame
	cloneTemplate.Visible = true
	
	local armour = worldModel:FindFirstChild("Armour")
	for i,e in ipairs(armour:GetChildren()) do
		if e:IsA("BasePart") then
			e.Transparency = 1
		end
	end
	
	local toolTable = toolsModule.CreateTool(toolPath,armour,isClient)
	
	toolTable:Interface("Init",armour,true)
end

if isClient then
	for _, toolPath in ipairs(alltoolPaths) do
		local className, _, configName = toolsModule.GetToolIdentifier(toolPath)
		if className and className == "Armours" and configName ~= "Default" then
			createIndex(toolPath)
		end
	end
end

return module