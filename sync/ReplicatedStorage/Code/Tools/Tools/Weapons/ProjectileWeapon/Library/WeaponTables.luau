local module = {}

function module.new(weaponTable,weaponConfig)
	local WeaponTables = {
		Data = {},
		WeaponTable = weaponTable,
		WeaponConfig = weaponConfig
	}

	for bodyPartname,data in pairs(weaponConfig.Data) do
		WeaponTables.Data[bodyPartname] = weaponTable.new(bodyPartname)
	end

	function WeaponTables:GetKeys()
		local keys = {}
		for bodyPartname,_ in pairs(self.Data) do
			table.insert(keys,bodyPartname)
		end

		return keys
	end
	
	function WeaponTables:GetWeaponTables()
		return self.Data
	end

	function WeaponTables:SetLevel(level:number)
		for _,weaponTable in pairs(self.Data) do
			weaponTable:SetLevel(level)
		end
	end

	function WeaponTables:SetDamageMultiplier(level:number)
		for _,weaponTable in pairs(self.Data) do
			weaponTable:SetDamageMultiplier(level)
		end
	end

	function WeaponTables:GetVariable(variable:string)
		return self.WeaponConfig[variable]
	end

	function WeaponTables:Destroy()
		for bodyPartname,weaponTable in pairs(self.Data) do
			weaponTable:Destroy()
		end
		table.clear(self)
	end

	return WeaponTables
end

return module
