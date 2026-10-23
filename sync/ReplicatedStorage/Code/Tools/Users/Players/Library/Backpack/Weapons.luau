local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local players = game:GetService("Players")
local isClient = game:GetService("RunService"):IsClient()

local weaponSlots = {"Weapon1","Weapon2","Weapon3"}

local function addWeapon(backPackModule,data,toolTable)
	local guidObject = toolTable.GUIDObject
	local tools = backPackModule.Tools
	local player = backPackModule.Player
	local character = backPackModule.Character

	if not isClient then
		data.Value = guidObject.Name
	end
	
	toolTable.Level = toolsModule.GetData(player,{"Player","Armour","Level"}).Value
	toolTable:Interface("Init",character)
	tools.Weapons[guidObject.Value] = toolTable
	
	return true
end

local function removeWeapon(backPackModule,data,toolTable)
	local guidObject = toolTable.GUIDObject
	
	if not isClient then
		data.Value = ""
	end
	
	backPackModule.Tools.Weapons[guidObject.Value] = nil

	return true
end

function module.Init(backPackModule)
	local tools = backPackModule.Tools
	local player = backPackModule.Player
	local character = backPackModule.Character
	
	for i, slot in ipairs(weaponSlots) do
		local toolTable = toolsModule.InitTool(player,{"Player",slot},character)
		if not toolTable then continue end
		local data = toolsModule.GetData(player,{"Player",slot})
		addWeapon(backPackModule,data,toolTable)
	end
end

function module.GiveOrTake(backPackModule,added,toolTable)	
	local player = backPackModule.Player
	for i, slot in ipairs(weaponSlots) do
		local data = toolsModule.GetData(player,{"Player",slot})
		if added then
			if not isClient and data.Value ~= "" then continue end
			if addWeapon(backPackModule,data,toolTable) then break end
		else
			if not isClient and data.Value ~= toolTable.GUIDObject.Name then continue end
			if removeWeapon(backPackModule,data,toolTable) then break end
		end
		
		if isClient then return end
	end
end

function module.ShootWeaponFunction(backPackModule)
	return function(pullTrigger)
		local character = backPackModule.Character
		local targetLock = backPackModule.Tools.TargetLock
		local weapons = backPackModule.Tools.Weapons
		
		local tool = character and character:FindFirstChildWhichIsA("Tool")
		local guidObject = tool and tool.GUIDObject
		
		if targetLock and weapons and guidObject then
			local weaponTable = weapons[guidObject.Value]
			if not weaponTable then return end
			weaponTable:Interface("RequestShoot",pullTrigger,false,true)
		end
	end
end

function module.ReloadWeaponFunction(backPackModule)
	return function()
		local character = backPackModule.Character
		local weapons = backPackModule.Tools.Weapons
		
		local tool = character and character:FindFirstChildWhichIsA("Tool")
		local guidObject = tool and tool.GUIDObject
		
		if weapons and guidObject then
			local weaponTable = weapons[guidObject.Value]
			if not weaponTable then return end
			weaponTable:Interface("RequestReload",false,true)
		end
	end
end

function module.Loop(backPackModule)
	if not isClient then return end
	
	local character = backPackModule.Character
	local targetLock = backPackModule.Tools.TargetLock
	
	local position,target = targetLock:Interface("GetTargetPosition")
	local guid, weaponTable = next(backPackModule.Tools.Weapons)
	if weaponTable then
		weaponTable:Interface("RequestSetAim",position,target,false,true)
	end
end

--local targetPosition = workspace.Camera.CFrame.Position + (workspace.Camera.CFrame.LookVector*100)
--weaponTable:Interface("UpdateTargetPosition",targetPosition)

return module
