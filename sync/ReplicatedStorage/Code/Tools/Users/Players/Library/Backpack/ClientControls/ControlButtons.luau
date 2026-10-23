local module = {}
local ContextActionService = game:GetService("ContextActionService")

export type ButtonParameters = {
	ActionName: string,
	Function: (string, Enum.UserInputState, InputObject) -> (),
	Visible: boolean,
	InputTypes: {Enum.KeyCode},
	ButtonText: string?,
	Position: UDim2?,
	Image: string?,
	Size: UDim2? -- Added Size property
}

function module.CreateBindAction(config: ButtonParameters)
	module.UnbindAction(config.ActionName)
	
	ContextActionService:BindAction(
		config.ActionName, 
		config.Function, 
		config.Visible, 
		unpack(config.InputTypes)
	)

	if not config.Visible then return end

	if config.ButtonText then
		ContextActionService:SetTitle(config.ActionName, config.ButtonText)
	end

	if config.Position then
		ContextActionService:SetPosition(config.ActionName, config.Position)
	end

	if config.Image then
		ContextActionService:SetImage(config.ActionName, config.Image)
	end

	-- Handle Size via GetButton
	if config.Size then
		local button = ContextActionService:GetButton(config.ActionName)
		if button then
			button.Size = config.Size
			button.Active = false
		else
			--warn("Could not find button for: " .. config.ActionName .. ". Size could not be set.")
		end
	end
end

function module.UnbindAction(actionName: string)
	ContextActionService:UnbindAction(actionName)
end


return module
