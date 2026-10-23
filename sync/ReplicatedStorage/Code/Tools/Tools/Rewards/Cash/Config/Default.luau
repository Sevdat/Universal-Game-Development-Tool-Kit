local debris = game:GetService("Debris")

return {
	ConfigName = script.Name,
	
	Name = "Cash",
	
	GetRewards = function(name,amount) 
		local rewards = script.Rewards
		return rewards:FindFirstChild(name or "Default") or rewards:FindFirstChild("Default")
	end,
	
}