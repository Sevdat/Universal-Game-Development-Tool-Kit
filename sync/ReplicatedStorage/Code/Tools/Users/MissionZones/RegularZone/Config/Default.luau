local debris = game:GetService("Debris")

return {
	ConfigName = script.Name,
	
	Guranteed = true,
	
	Name = "Cash",
	Amount = 20,
	Chance = 1,
	
	Reward = script.Reward.Cash,
	
	GiveAura = function(model,despawnAuraTime)

	end
	
}