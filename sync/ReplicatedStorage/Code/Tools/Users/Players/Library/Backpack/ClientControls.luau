local module = {}

local controlButtons = require(script.ControlButtons)

export type Controls = {
	TriggerArmourFunction: () -> (),
	TriggerFlightFunction: () -> (),
	BoostFlightFunction: () -> (),
	
	ShootWeaponFunction: () -> (),
	ReloadWeaponFunction: () -> (),
	SwitchWeaponFunction: () -> (),
}

function module.BindControls(controls: Controls)		
	if controls.TriggerFlightFunction then
		controlButtons.CreateBindAction({
			ActionName = "TriggerFlightFunction",
			Function = function(actionName, inputState, inputObject)
				if inputState == Enum.UserInputState.Begin then
					controls.TriggerFlightFunction()
				end
				return Enum.ContextActionResult.Pass
			end,
			Visible = true,
			InputTypes = {Enum.KeyCode.F,Enum.KeyCode.ButtonR1},
			ButtonText = "Fly",
			Position = UDim2.new(0.7, 0, 0, 0),
			Size = UDim2.new(0, 40, 0, 40)
		})
	end
	
	if controls.ShootWeaponFunction then
		controlButtons.CreateBindAction({
			ActionName = "ShootWeaponFunction",
			Function = function(actionName, inputState, inputObject)
				if inputState == Enum.UserInputState.Begin then
					controls.ShootWeaponFunction(true)
				elseif inputState == Enum.UserInputState.End
					or inputState == Enum.UserInputState.Cancel then
					controls.ShootWeaponFunction(false)
				end

				return Enum.ContextActionResult.Pass
			end,
			Visible = true,
			InputTypes = {Enum.UserInputType.MouseButton1},
			ButtonText = "Shoot",
			Position = UDim2.new(0.15, 0, 0.3, 0),
			Size = UDim2.new(0, 50, 0, 50)
		})
	end
	if controls.ReloadWeaponFunction then
		controlButtons.CreateBindAction({
			ActionName = "ReloadWeaponFunction",
			Function = function(actionName, inputState, inputObject)
				if inputState == Enum.UserInputState.Begin then
					controls.ReloadWeaponFunction()
				end
				return Enum.ContextActionResult.Pass
			end,
			Visible = true,
			InputTypes = {Enum.KeyCode.R},
			ButtonText = "Reload",
			Position = UDim2.new(0.4, 0, 0.1, 0),
			Size = UDim2.new(0, 50, 0, 50)
		})
	end
end

function module.UnbindAllControls()
	controlButtons.UnbindAction("TriggerArmourFunction")
	controlButtons.UnbindAction("TriggerFlightFunction")
	controlButtons.UnbindAction("BoostFlightFunction")
	controlButtons.UnbindAction("ShootWeaponFunction")
	controlButtons.UnbindAction("ReloadWeaponFunction")
	controlButtons.UnbindAction("SwitchWeaponFunction")
end

return module
