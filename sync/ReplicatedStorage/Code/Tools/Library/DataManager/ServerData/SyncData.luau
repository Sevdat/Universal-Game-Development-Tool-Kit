local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

local playerData = script.PlayerData

function module.Load(player,profile)
	local clonePlayerData = playerData:Clone()

	profile = profile.Data.Default

	local playerValues = clonePlayerData.Player

	playerValues.Cash.Value = profile.Cash
	playerValues.RobuxSpent.Value = profile.RobuxSpent
	playerValues.CashMultiplier.Value = profile.CashMultiplier
	playerValues.Rebirth.Value = profile.Rebirth

	module.SyncWeapons(profile,playerValues,true)	
	module.SyncArmour(profile,playerValues.Armour,true)
	module.SyncTycoon(profile,clonePlayerData.Tycoon,true)
	
	clonePlayerData.Parent = player
end

function module.Save(player,profile)
	local playerData = player:FindFirstChild("PlayerData")
	if not profile or not playerData then return end

	profile = profile.Data.Default

	local playerValues = playerData.Player

	profile.Cash = playerValues.Cash.Value
	profile.RobuxSpent = playerValues.RobuxSpent.Value
	profile.CashMultiplier = playerValues.CashMultiplier.Value
	profile.Rebirth = playerValues.Rebirth.Value

	module.SyncWeapons(profile,playerValues,false)	
	module.SyncArmour(profile,playerValues.Armour,false)
	module.SyncTycoon(profile,playerData.Tycoon,false)
end

function module.SyncTycoon(profile,tycoonData,isLoading)		
	local armoursInTycoonStands = profile.ArmoursInTycoonStands

	if isLoading then
		for armourName,armourInStand in pairs(armoursInTycoonStands) do
			local armourPath = toolsModule.GetString(armourInStand.ArmourId)
			local level = armourInStand.Level
			local collectButtonTime = armourInStand.CollectButtonTime

			local armourStand = tycoonData:FindFirstChild(armourName)
			if armourPath then
				armourStand.Value = armourPath
				armourStand.Level.Value = level
				armourStand.CollectButtonTime.Value = collectButtonTime
			end
		end
	else
		for i,armourStand in ipairs(tycoonData:GetChildren()) do
			if not string.find(armourStand.Name, "ArmourStand") then continue end
			
			local armourId = toolsModule.GetID(armourStand and armourStand.Value or "")
			local level = armourStand and armourStand.Level
			local collectButtonTime = armourStand.CollectButtonTime

			armoursInTycoonStands[armourStand.Name] = armourId and {
				ArmourId = armourId,
				Level = level and level.Value or 1,
				CollectButtonTime = collectButtonTime and collectButtonTime.Value or os.time()
			} or nil
		end
	end
end

function module.SyncArmour(profile,armour,isLoading)
	if isLoading then
		if not profile.EquippedArmour then return end
		local armourPath = toolsModule.GetString(profile.EquippedArmour.ArmourId)
		local level = profile.EquippedArmour.Level

		if armourPath then
			armour.Value = armourPath
			armour.Level.Value = level
		end
	else
		local armourId = toolsModule.GetID(armour and armour.Value or "")
		local level = armour and armour.Level

		profile.EquippedArmour = armourId and {
			ArmourId = armourId,
			Level = level and level.Value or 0
		} or nil
	end
end

function module.SyncWeapons(profile,playerValues,isLoading)		
	local weaponInProfile = profile.Weapons
	local order = {"Weapon1", "Weapon2", "Weapon3"}
	
	if isLoading then
		for i,weaponId in ipairs(weaponInProfile) do
			local weaponPath = toolsModule.GetString(weaponId)
			local weaponData = playerValues:FindFirstChild("Weapon"..i)
			if weaponPath and weaponData then
				weaponData.Value = weaponPath
			end
		end
	else
		for i,weaponName in ipairs(order) do
			local weaponData = playerValues:FindFirstChild(weaponName)
			local weaponId = toolsModule.GetID(weaponData and weaponData.Value or "")
			weaponInProfile[i] = weaponId
		end
	end
end

return module
