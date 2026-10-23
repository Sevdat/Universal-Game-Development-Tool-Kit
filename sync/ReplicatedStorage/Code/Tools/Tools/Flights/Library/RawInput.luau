local module = {}

local starterPlayer = game:GetService("StarterPlayer")
local inputContexts = starterPlayer and starterPlayer.PlayerModule.InputContexts

local cameraContext = inputContexts and inputContexts.CameraContext
local characterContext = inputContexts and inputContexts.CharacterContext

local cameraRotation = cameraContext and cameraContext.CameraRotationAction
local moveAction = characterContext and characterContext.MoveAction

function module.GetLocalPlayerMoveVector(player):Vector2
	return moveAction:GetState()
end

function module.GetCameraDelta()
	return cameraRotation:GetState().X/50
end

return module
