local isClient = game:GetService("RunService"):IsClient()
local weaponTables = require(script.Parent.Parent.Library.WeaponTables)
local weaponTable = require(script.WeaponTable)
local weaponConfig = require(script.WeaponConfig)

return {
	ConfigName = script.Name,

	GetWeaponTables = function(self)
		return weaponTables.new(weaponTable,weaponConfig)
	end
}