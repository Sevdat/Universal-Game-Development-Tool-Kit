local module = {}

local starterPlayer = game:GetService("StarterPlayer")
local inputContexts = starterPlayer and starterPlayer.PlayerModule.InputContexts

local cameraContext = inputContexts and inputContexts.CameraContext
local characterContext = inputContexts and inputContexts.CharacterContext

local cameraRotationAction = cameraContext and cameraContext.CameraRotationAction
local moveAction = characterContext and characterContext.MoveAction
local zoomAction = cameraContext and cameraContext.CameraZoomAction


local UserInputService = game:GetService("UserInputService")
UserInputService.MouseDeltaSensitivity = UserInputService.TouchEnabled and 4 or UserInputService.MouseDeltaSensitivity


function module.GetMoveVector(player):Vector2
	return moveAction:GetState()
end

function module.GetCameraRotation()
	return cameraRotationAction:GetState()
end

function module.GetZoomDelta()
	return zoomAction:GetState()
end

function module.Enable(enable)
	zoomAction.Enabled = enable
	cameraRotationAction.Enabled = enable
end

return module
