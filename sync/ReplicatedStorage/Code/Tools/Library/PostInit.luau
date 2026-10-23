local module = {}

module.PostInit = {}

function module.AddToPostInit(func:()->())
	if func then
		module.PostInit[func] = func
	end
end

function module.RemoveFromPostInit(func:()->())
	if func and module[func] then
		module.PostInit[func] = nil
	end
end

function module.Init()
	for _,func in pairs(module.PostInit) do
		func()
	end
end

return module
