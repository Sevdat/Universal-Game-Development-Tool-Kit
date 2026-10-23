local Backpack = {}
Backpack.__index = Backpack

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local isClient = game:GetService("RunService"):IsClient()
local localPlayer = isClient and game.Players.LocalPlayer or nil
local clientControls = require(script.ClientControls)

local options = {
	Armours = require(script.Armour),
	Weapons = require(script.Weapons),
	Flights = require(script.Flight),
	TargetLocks = require(script.TargetLock),
	Cameras = require(script.Camera)	
}
local ordered = {"Armours","Weapons","Flights","TargetLocks","Cameras"}

function Backpack.new(player)
	local self = setmetatable({}, Backpack)

	self.Player = player
	self.Character = player.Character
	self.HumanoidRootPart = self.Character.HumanoidRootPart
	self.Humanoid = self.Character.Humanoid
	self.Animator = self.Humanoid.Animator

	self.Tools = {
		Weapons = {},
		Flight = nil,
		Armour = nil,	
		TargetLock = nil,
		Camera = nil
	}

	self.LoopFunction = nil

	self:Init()	
	
	return self
end

function Backpack:Init()
	for i, name in ipairs(ordered) do
		options[name].Init(self)
	end

	self.LoopFunction = self.LoopFunction or function()
		options.Weapons.Loop(self)
	end
	
	if localPlayer == self.Player then
		toolsModule.AddToLoop("RenderStepped",self.LoopFunction)
	end
	
	self:BindControls()
end

function Backpack:RefreshTools(child,added:boolean)
	if not child:IsA("StringValue") then return end
	local name = child.Name

	local toolTable = toolsModule.CreateTool(child)
	local className, _, _ = toolsModule.GetToolIdentifier(child)
	
	local getOption = options[className]

	if getOption then
		getOption.GiveOrTake(self,added,toolTable)
	end
	
	self:BindControls()
end

function Backpack:BindControls()
	if not isClient or self.Player ~= localPlayer then return end

	if not self.Tools.Armour and self.Tools.Flight then
		self.Tools.Flight:Interface("RequestFlight",false,false,true)
	end

	clientControls.BindControls({		
		TriggerFlightFunction = self.Tools.Flight and options.Flights.TriggerFlightFunction(self),
		
		ShootWeaponFunction = next(self.Tools.Weapons) and options.Weapons.ShootWeaponFunction(self),
		
		ReloadWeaponFunction = next(self.Tools.Weapons) and options.Weapons.ReloadWeaponFunction(self)
	})
end

function Backpack:Destroy()
	toolsModule.RemoveFromLoop("RenderStepped",self.LoopFunction)
	if localPlayer == self.Player then
		clientControls.UnbindAllControls()
	end
	
	for key,toolTable in pairs(self.Tools) do
		if key == "Weapons" then
			for _,weaponTable in pairs(toolTable) do
				local weaponGUIDObject = weaponTable.GUIDObject
				if weaponTable then
					weaponGUIDObject:Destroy()
				end
			end
		else
			local toolGUIDObject = toolTable.GUIDObject
			if toolGUIDObject then
				toolGUIDObject:Destroy()
			end
		end
	end
	
end

return Backpack