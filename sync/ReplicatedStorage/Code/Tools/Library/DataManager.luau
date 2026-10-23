local module = {}

local isServer = game:GetService("RunService"):IsServer()
local serverData = require(script.ServerData)

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function module.GetData(player,dataPath:{})
	local playerData = player and player:FindFirstChild("PlayerData")
	if not playerData then return end

	local data = playerData
	for _,path in ipairs(dataPath) do
		data = data:FindFirstChild(path)
		if not data then return end
	end

	return data
end

function module.UpdateData(player,dataPath:{},newValue,increment:boolean)
	local playerData = player and player.Parent and player:FindFirstChild("PlayerData")
	if not playerData then return end

	local data = playerData
	for _,path in ipairs(dataPath) do
		data = data:FindFirstChild(path)
		if not data then return end
	end

	if increment then
		data.Value += newValue
	else
		data.Value = newValue
	end
end

function module.UpdateFreeTycoonData(player,armourPath)
	local playerData = player and player.Parent and player:FindFirstChild("PlayerData")
	if not playerData then return end

	local tycoon = playerData:FindFirstChild("Tycoon")
	if not tycoon then return end

	for _,tycoonData in ipairs(tycoon:GetChildren()) do
		if tycoonData.Value ~= "" then continue end
		tycoonData.Value = armourPath
		tycoonData:FindFirstChild("CollectButtonTime").Value = workspace:GetServerTimeNow()
		tycoonData:FindFirstChild("Level").Value = 0
		return true
	end
	return false
end

function module.AmountOfFreeTycoonSlots(player)
	local playerData = player and player.Parent and player:FindFirstChild("PlayerData")
	if not playerData then return end

	local tycoon = playerData:FindFirstChild("Tycoon")
	if not tycoon then return end

	local amount = 0
	
	for _,tycoonData in ipairs(tycoon:GetChildren()) do
		amount += tycoonData.Value == "" and 1 or 0
	end

	return amount
end

function module.InitTool(player,dataPath:{},searchInInstance)
	local playerData = player and player.Parent and player:FindFirstChild("PlayerData")
	if not playerData then return end

	local data = playerData
	for _,path in ipairs(dataPath) do
		data = data:FindFirstChild(path)
		if not data then return end
	end
	
	local name = data.Value
	if name == "" then return end
	local guidObject = searchInInstance and searchInInstance:FindFirstChild(name) or nil

	if not guidObject and isServer then
		guidObject = Instance.new("StringValue")
		guidObject.Name = name
	end
	
	local toolTable = nil
	if guidObject then
		toolTable = toolsModule.CreateTool(guidObject,searchInInstance)
	end

	return toolTable
end

return module

--function module.UpdateData(player,dataPath:{},newValue)
--	local playerData = player and player.Parent and player:FindFirstChild("PlayerData")
--	if not playerData then return end

--	local data = playerData
--	for _,path in ipairs(dataPath) do
--		data = data:FindFirstChild(path)
--		if not data then return end
--	end
--	data.Value = newValue
--end