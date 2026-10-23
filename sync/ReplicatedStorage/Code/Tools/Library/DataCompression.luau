local module = {}

local hash_djb2 = require(script.Hash_djb2)

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local allToolPaths = toolsModule.GetAllToolPaths()

module.IdToStringName = {}
module.StringNameToId = {}

for _, toolPath in ipairs(allToolPaths) do
	if typeof(toolPath) ~= "string" then continue end
	
	local id = hash_djb2(toolPath)
	if module.IdToStringName[id] then 
		warn("collision "..id.." "..toolPath) 
	end
	module.IdToStringName[id] = toolPath
	module.StringNameToId[toolPath] = id
end

function module.GetID(toolPath)
	return module.StringNameToId[toolPath]
end

function module.GetString(id)
	return module.IdToStringName[id]
end

return module
