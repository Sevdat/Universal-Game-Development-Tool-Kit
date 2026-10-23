local module = {}

local httpService = game:GetService("HttpService")
local isClient = game:GetService("RunService"):IsClient()
local allConfig = game:GetService("CollectionService"):GetTagged("Config")

module.Tools = {}
module.ToolMetatables = {}

for i,config in ipairs(allConfig) do
	local toolBehaviour = config.Parent
	local toolClass = toolBehaviour.Parent

	local toolPath = toolClass.Name.."_"..toolBehaviour.Name.."_"

	local requiredToolBehaviour = require(toolBehaviour)

	for _, configData in ipairs(config:GetChildren()) do
		if not configData:IsA("ModuleScript") then continue end

		module.Tools[toolPath..configData.Name] = {
			ToolBehaviour = requiredToolBehaviour,
			ToolConfig = require(configData),
			
			ClassName = toolClass.Name,
			BehaviourName = toolBehaviour.Name,
			ConfigName = configData.Name
		}
	end
end

function module.GetAllToolPaths()
	local allToolPaths = {}
	for toolPath,_ in pairs(module.Tools) do
		table.insert(allToolPaths,toolPath)
	end
	return allToolPaths
end

function module.GetConfig(toolPath:string)
	local toolData = module.Tools[toolPath]
	return toolData and toolData.ToolConfig
end

function module.CreateTool(data:string|StringValue,parentTo:Instance?,forceGUID:boolean?)
	local guidObject,toolData = nil,nil
	
	if type(data) == "string" then		
		guidObject = Instance.new("StringValue")
		guidObject.Name = data
		toolData = module.Tools[data]
	elseif data:IsA("StringValue") then
		guidObject = data
		toolData = module.Tools[guidObject.Name]
	end
	
	if not toolData then return print("No Data: ",data) end

	local toolTable = module.ToolMetatables[guidObject.Value]
	
	if not toolTable then
		if guidObject.Value == "" and (not isClient or forceGUID) then
			guidObject.Value = httpService:GenerateGUID(false)
		end

		toolTable = toolData.ToolBehaviour.new(toolData.ToolConfig,guidObject)
		
		module.ToolMetatables[guidObject.Value] = toolTable
	end

	guidObject.Parent = parentTo or guidObject.Parent
	
	return toolTable
end

function module.GetAllTools(instance:Instance,classNames:{string},create:boolean?)
	local allTools = {}
	for i,child in ipairs(instance:GetChildren()) do
		if not child:IsA("StringValue") then continue end
		
		local className, _, _ = module.GetToolIdentifier(child)
		
		if not classNames[className or ""] then continue end
		
		if not allTools[className] then
			allTools[className] = {}
		end
		
		local toolTable = module.GetTool(child) or create and module.CreateTool(child)
		if toolTable then
			table.insert(allTools[className],toolTable)
		end
	end
	return allTools
end

function module.SetToolAttribute(instance:Instance,guid:string)
	instance:SetAttribute("GUID",guid)
end

function module.GetTool(data:string|StringValue|Instance):{}	
	local guid = typeof(data) == "string" and data or 
				 data:IsA("StringValue") and data.Value or 
				 data:IsA("Instance") and data:GetAttribute("GUID")
				 or nil
				 
	return guid and module.ToolMetatables[guid]
end

function module.GetGUIDObject(data:string|StringValue|Instance):{}	
	local toolData = data and module.GetTool(data)
	return toolData and toolData.GUIDObject
end

function module.GetToolIdentifier(data:string|StringValue|Instance):(string,string,string)
	local toolPath = nil
	
	if typeof(data) == "string" then
		toolPath = data
	elseif data:IsA("StringValue") then
		toolPath = data.Name
	elseif data:IsA("Instance") then
		local guidObject = module.GetGUIDObject(data)
		toolPath = guidObject and guidObject.Name
	end
	
	local toolData = toolPath and module.Tools[toolPath]
	
	if toolData then
		return toolData.ClassName, toolData.BehaviourName, toolData.ConfigName
	end

	return nil,nil,nil
end

function module.DestroyTool(data:string|StringValue|Instance)
	local guidObject = module.GetGUIDObject(data)
	local GUID = guidObject and guidObject.Value
	local toolPath = guidObject and guidObject.Name
	if not GUID then return end
	
	local toolTable = module.ToolMetatables[GUID]
	module.ToolMetatables[GUID] = nil
	
	if not toolTable then return end
	
	local className, _, _ = module.GetToolIdentifier(toolPath)
	
	if toolTable then
		local toolInterface = toolTable[className:sub(1, -2).."Interface"]

		task.delay(5,function()
			setmetatable(toolTable, nil)
			table.clear(toolTable)
			table.freeze(toolTable)

			setmetatable(toolInterface, nil)
			table.clear(toolInterface)
			table.freeze(toolInterface)
		end)
	end
end

return module
