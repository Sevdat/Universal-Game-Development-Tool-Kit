local module = {}

local runService = game:GetService("RunService")
local isClient = runService:IsClient()

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

module.Heartbeat = {}
module.RenderStepped = {}

function module.AddToLoop(loopType:string,func:()->())
	if func and loopType and module[loopType] then
		module[loopType][func] = func
	end
end

function module.RemoveFromLoop(loopType:string,func:()->())
	if func and loopType and module[loopType] and module[loopType][func] then
		module[loopType][func] = nil
	end
end


toolsModule.AddToPostInit(function()
	runService.Heartbeat:Connect(function(dt)
		for _, func in pairs(module.Heartbeat) do
			func(dt)
		end
	end)

	if isClient then
		runService.RenderStepped:Connect(function(dt)
			for _, func in pairs(module.RenderStepped) do
				func(dt)
			end
		end)
	end
end)

return module
