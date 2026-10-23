
local enum = {}
return {
	ConfigName = script.Name,
	
	Name = "Armour",
	
	GetRewards = function(name,amount) 
		local rewards = script.Rewards
		return rewards:FindFirstChild(name or "Default") or rewards:FindFirstChild("Default")
	end,
	
}