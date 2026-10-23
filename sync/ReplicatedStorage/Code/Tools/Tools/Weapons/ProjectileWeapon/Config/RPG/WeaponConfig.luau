local info = script.Parent

return {
	Damage = 40,
	Speed = 200,
	Acceleration = Vector3.zero,
	Distance = 1000,
	Radius = 100,
	MaxAmmo = 10,
	FireRate = 0.8,
	ReloadTime = 2.249,

	MotionType = "Follow",
	IsAutomatic = true,
	CanPierce = false,
	
	ServerDelayTime = 0.1,
	ClientDelayTime = 0,

	ReloadSound = info.Sounds.Reload,
	ReloadAnimation = info.Animations.Reload,
	IdleAnimation = info.Animations.Idle,

	HitSound = info.Sounds.Hit,
	KillSound = info.Sounds.Death,

	ClientModel = info.Model.ClientModel,
	ServerModel = info.Model.ServerModel,
	
	HitEffect = info.HitEffect.Part,

	Data = {
		RightHand = {
			Projectile = info.Projectile.Rocket,

			FireSound = info.Sounds.Fire,

			AttackAnimation = info.Animations.Attack,
		}
	}
}
