local info = script.Parent

return {
	Damage = 10,
	Speed = 200,
	Acceleration = Vector3.zero,
	Distance = 1000,
	Radius = 0,
	MaxAmmo = 60,
	FireRate = 0.07,
	ReloadTime = 1.358,

	MotionType = "Linear",
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
			Projectile = info.Projectile.Bullet,

			FireSound = info.Sounds.Fire,

			AttackAnimation = info.Animations.Attack,
		}
	}
}
