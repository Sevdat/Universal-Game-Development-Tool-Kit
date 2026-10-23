local module = {}

local tween = require(script.Parent.Parent.Library.Tween)
local isClient = game:GetService("RunService"):IsClient()
local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local gui = isClient and game.Players.LocalPlayer:FindFirstChild("PlayerGui") or nil
local screenGUI = gui and gui:FindFirstChild("ScreenGui")
local allMenu = screenGUI and screenGUI:FindFirstChild("AllMenu")

local indexMenu = allMenu and allMenu:FindFirstChild("Gear")
local scrollingFrame = indexMenu and indexMenu.ScrollingFrame
local template = scrollingFrame and scrollingFrame.Template

local items = require(script.Items)
local suffix = require(script.Suffix)
local remote = require(script.Remote)
local buyTool = remote.BuyTool
local sellTool = remote.SellTool

function createTools(toolPath:string,item:{})
	local className, behaviourName, configName = toolsModule.GetToolIdentifier(toolPath)
	local config = toolsModule.GetConfig(toolPath)
	local key, weaponTable = next(config.GetWeaponTables():GetWeaponTables())
	
	local price = item.Price
	local currency = item.Currency
	local description = item.Description
	local layoutOrder = item.LayoutOrder
	
	local distance = item.Distance
	local offset = item.Offset
	
	local cloneTemplate = template:Clone()
	cloneTemplate.ItemName.Text = configName
	cloneTemplate.Description.Text = item.Description
	cloneTemplate.Price.Text = suffix.Shorten(price)
	cloneTemplate.LayoutOrder = layoutOrder
	
	local viewportFrame = cloneTemplate.ViewportFrame
	local worldModel = viewportFrame.WorldModel
	local character = worldModel.Character
	
	character.PrimaryPart.Transparency = 1
	
	weaponTable:Init(character)
	weaponTable:Equip(true)
	
	local cam = Instance.new("Camera")
	cam.Parent = viewportFrame
	viewportFrame.CurrentCamera = cam

	cam.CFrame = CFrame.lookAt(
		distance,
		character.PrimaryPart.Position
	) + offset

	local purchaseButton = tween.Button(cloneTemplate.Purchase)
	local sellButton = tween.Button(cloneTemplate.Sell)
	
	local toolExists = remote.ToolExists(game.Players.LocalPlayer,toolPath) and true or false
	purchaseButton.Visible = not toolExists
	sellButton.Visible = toolExists
	
	purchaseButton.MouseButton1Click:Connect(function()
		if remote.Purchase(game.Players.LocalPlayer,toolPath) then
			buyTool:FireServer(toolPath)
			purchaseButton.Visible = false
			sellButton.Visible = true
		end
	end)
	
	sellButton.MouseButton1Click:Connect(function()
		if remote.Sell(game.Players.LocalPlayer,toolPath) then
			sellTool:FireServer(toolPath)
			purchaseButton.Visible = true
			sellButton.Visible = false
		end
	end)

	cloneTemplate.Visible = true

	cloneTemplate.Parent = scrollingFrame
end

if isClient then
	for toolPath, item in pairs(items) do
		createTools(toolPath,item)
	end
end

return module