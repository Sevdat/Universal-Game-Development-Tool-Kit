local module = {}

local centralLink = require(script.Parent.CentralLink)
table.insert(centralLink,module)

module.PostInit = require(script.Library.PostInit)

function module.AddToPostInit(func:()->())
	module.PostInit.AddToPostInit(func)
end

module.Loops = require(script.Library.Loop)

function module.AddToLoop(loopType:string,func:()->())
	module.Loops.AddToLoop(loopType,func)
end

function module.RemoveFromLoop(loopType:string,func:()->())
	module.Loops.RemoveFromLoop(loopType,func)
end


module.Folders = require(script.Library.Folders)

module.Tools = require(script.Library.Tools)

function module.GetAllToolPaths()
	return module.Tools.GetAllToolPaths()
end

function module.GetConfig(toolPath:string)
	return module.Tools.GetConfig(toolPath)
end

function module.CreateTool(toolPath:string,parentTo:Instance,forceGUID:boolean?):{}
	return module.Tools.CreateTool(toolPath,parentTo,forceGUID)
end

function module.GetTool(guid:string|StringValue|Instance):{}
	return module.Tools.GetTool(guid)
end

function module.GetAllTools(instance:Instance,classNames:{string},create:boolean?)
	return module.Tools.GetAllTools(instance,classNames,create)
end

function module.SetToolAttribute(instance,guid)
	module.Tools.SetToolAttribute(instance,guid)
end

function module.GetGUIDObject(data:string|StringValue|Instance):{}	
	return module.Tools.GetGUIDObject(data)
end

function module.GetToolIdentifier(data:string|StringValue|Instance):(string,string,string)
	return module.Tools.GetToolIdentifier(data)
end

function module.DestroyTool(data:string|StringValue|Instance)
	return module.Tools.DestroyTool(data)
end

module.DataCompression = require(script.Library.DataCompression)

function module.GetID(toolPath:string)
	return module.DataCompression.GetID(toolPath)
end

function module.GetString(id:number)
	return module.DataCompression.GetString(id)
end


module.DataManager = require(script.Library.DataManager)

function module.GetData(player,dataPath:{})
	return module.DataManager.GetData(player,dataPath)
end

function module.UpdateData(player,dataPath:{},newValue,increment)
	module.DataManager.UpdateData(player,dataPath,newValue,increment)
end

function module.UpdateFreeTycoonData(player,armourPath)
	return module.DataManager.UpdateFreeTycoonData(player,armourPath)
end

function module.AmountOfFreeTycoonSlots(player)
	return module.DataManager.AmountOfFreeTycoonSlots(player)
end

function module.InitTool(player,dataPath:{}, searchInInstance)
	return module.DataManager.InitTool(player,dataPath, searchInInstance)
end


module.ProcessReceipt = require(script.Library.ProcessReciept)

function module.StealPrompt(player:Players,rarity:string,func:()->())
	local productId = rarity== "Common" and 3585698172 
		or rarity== "Rare" and 3585698172 
		or rarity== "Epic" and 3585698172 
		or rarity== "Mythic" and 3585698172 
		or rarity== "Legendary" and 3585698172 
		or nil
	
	if not productId then return end
	module.ProcessReceipt.AddToPendingData(player, productId,func)
end

function module.StarterPackPrompt(player:Players,func:()->())
	local productId = 3718415795

	if not productId then return end
	module.ProcessReceipt.AddToPendingData(player, productId,func)
end

function module.CashPrompt(player:Players,amount:string,func:()->())
	local productId = amount == 100_000 and 3718399363 
		or amount == 500_000 and 3718399873 
		or amount == 2_000_000 and 3718400086 
		or amount == 20_000_000 and 3718400286 
		or amount == 500_000_000 and 3718400414 
		or amount == 1_000_000_000 and 3718400539 
		or nil

	if not productId then return end
	module.ProcessReceipt.AddToPendingData(player, productId,func)
end

function module.LuckyBlockPrompt(player:Players,rarity:string,func:()->())
	local productId = rarity == "Epic" and 3718491159 
		or rarity == "Mythic" and 3718494954
		or rarity == "Legendary" and 3718495178
		or nil

	if not productId then return end
	module.ProcessReceipt.AddToPendingData(player, productId,func)
end

function module.DonationPrompt(player:Players,amount:string,func:()->())
	local productId = amount == 1_000_000 and 3718401095 
		or nil

	if not productId then return end
	module.ProcessReceipt.AddToPendingData(player, productId,func)
end

module.GUI = require(script.Library.GUI)
module.Skybox = require(script.Library.Skybox)

module.Folders.InitFolders()

task.delay(2,function()
	module.PostInit.Init()
	
	if game:GetService("RunService"):IsClient() then
		script.Library["Relaxing Samba rhythm"]:Play()
	end
end)

return module