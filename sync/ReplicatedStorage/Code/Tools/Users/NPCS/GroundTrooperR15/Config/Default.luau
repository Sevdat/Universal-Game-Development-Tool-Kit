return {
	ConfigName = script.Name,
	
	Name = "Rifleman",
	ServerModel = script.ServerModel.NPCS_GroundTrooperR15_Default,
	ClientModel = script.ClientModel.Default,
	Speed = 45,
	MaxHealth = 100,
	RespawnTime = 5,
	Scale = script.ClientModel.Default,
	
	WeaponTools = {
		"Weapons_ProjectileWeapon_Rifle"
	},
	
	Idle = script.Animations.Idle,
	Run = script.Animations.Run,
	
	GetMuzzle = function(activeClientModel)
		return activeClientModel.Tool.Muzzle
	end,
}