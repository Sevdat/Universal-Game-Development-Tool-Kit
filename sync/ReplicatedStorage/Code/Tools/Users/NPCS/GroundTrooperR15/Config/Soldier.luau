return {
	ConfigName = script.Name,
	
	Name = "Rifleman",
	ServerModel = script.ServerModel.NPCS_GroundTrooperR15_Default,
	ClientModel = script.ClientModel.Soldier,
	Speed = 45,
	MaxHealth = 100,
	RespawnTime = 5,
	Scale = script.ClientModel.Soldier,
	
	Idle = script.Animations.Idle,
	Run = script.Animations.Run,
	
	GetMuzzle = function(activeClientModel)
		return activeClientModel.Tool.Muzzle
	end,
}