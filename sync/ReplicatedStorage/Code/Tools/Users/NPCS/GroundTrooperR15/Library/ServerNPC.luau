local isServer = game:GetService("RunService"):IsServer()
local isStudio = game:GetService("RunService"):IsStudio()

local movement = require(script.Movement)

local movementInterval = 0.3
local defaultHitboxSize = Vector3.new(7.557, 7.363, 6.639)

local ServerNPC = {}
ServerNPC.__index = ServerNPC

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

function ServerNPC.new(npcTable, serverDummy)
	local self = setmetatable({}, ServerNPC)
	
	self.NPCTable = npcTable
	self.Config = self.NPCTable.Config
	self.GUIDObject = self.NPCTable.GUIDObject

	self.Model = serverDummy
	self.Hitbox = nil

	self.Health = nil
	self.CanMove = nil
	self.TargetHRP = nil
	self.RespawnTime = nil
	
	self.SpawnPoint = nil
	self.MovementBoundry = nil
	self.Speed = nil
	
	self.Scale = nil

	self.NextMovementUpdate = 0

	return self
end

function ServerNPC:Init()	
	self.Hitbox = self.Model.Hitbox

	self.Health = self.Hitbox.Health
	self.CanMove = self.Hitbox.CanMove
	self.TargetHRP = self.Hitbox.TargetHRP
	self.RespawnTime = self.Hitbox.RespawnTime

	self.SpawnPoint = self.Model.SpawnPoint
	self.MovementBoundry = self.Model.MovementBoundry
	
	self.SpawnPoint.Transparency = isStudio and 0.7 or 1
	self.MovementBoundry.Transparency = isStudio and 0.7 or 1
	self.Hitbox.Transparency = isStudio and 0.7 or 1
	
	self.Speed = self.Config.Speed

	if isServer then
		self.Scale = self.Config.ClientModel:GetScale()
		self.Hitbox.Size = defaultHitboxSize*self.Scale
		self.Hitbox.Position = self.MovementBoundry.Position + Vector3.new(0,self.Hitbox.Size.Y / 2,0) 
	end
	
	toolsModule.SetToolAttribute(self.Model,self.GUIDObject.Value)
end



function ServerNPC:Movement()
	local timeNow = workspace:GetServerTimeNow()
	if not self.CanMove.Value or self.NextMovementUpdate > timeNow then return end
	self.NextMovementUpdate = timeNow + movementInterval

	movement.MovementLogicServer(
		self.Hitbox, 
		self.MovementBoundry, 
		self.TargetHRP.Value, 
		self.Speed, 
		movementInterval
	)
end

return ServerNPC
