local module = {}

local buttonModules = {
	Shop = require(script.Shop),
	Gear = require(script.Gear),
	Index = require(script.Index),
	Rebirth = require(script.Rebirth),
	Fusion = require(script.Fusion),
} 

function module.OpenMenu(name)
	for moduleName, buttonModule in pairs(buttonModules) do
		if name == moduleName then
			buttonModule.Menu.Visible = not buttonModule.Menu.Visible
		else
			buttonModule.Menu.Visible = false
		end
	end
end

function module.CloseAllMenu()
	module.OpenMenu("")
end

for name,buttonModule in pairs(buttonModules) do
	if buttonModule.Open then
		buttonModule.Open.MouseButton1Click:Connect(function()
			module.OpenMenu(name)
		end)
	end
	
	if buttonModule.Close then
		buttonModule.Close.MouseButton1Click:Connect(function()
			buttonModule.Menu.Visible = false
		end)
	end
end

return module
