local debris = game:GetService("Debris")

return {
	ConfigName = script.Name,
	
	Name = "Coin",
	
	GetRewards = function(name,amount) 
		return script:FindFirstChild(name or "Default")
	end,
	
}