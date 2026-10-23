local info = script.Parent

return {
	Damage = 50,
	Speed = 400,
	Acceleration = Vector3.zero,
	Distance = 1000,
	Radius = 0,
	MaxAmmo = 10,
	FireRate = 0.9,
	ReloadTime = 1.358,

	MotionType = "Linear",
	IsAutomatic = false,
	CanPierce = true,
	
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
			Projectile = info.Projectile.Bullet,

			FireSound = info.Sounds.Fire,

			AttackAnimation = info.Animations.Attack,
		}
	}
}
