local module = {}

local players = game:GetService("Players")

local function IsPlayer(armourPart)
	return players:GetPlayerFromCharacter(armourPart:FindFirstAncestorWhichIsA("Model"))
end 

function module.WeldParts(armourPart, target)
	if not armourPart or not target then return end
	
	local weld = armourPart:FindFirstChild("_StandWeld")
	
	if not weld then
		weld = Instance.new("WeldConstraint")
		weld.Name = "_StandWeld"
		weld.Parent = armourPart
	end
	
	armourPart.Anchored = false
	weld.Enabled = false
	weld.Part0 = armourPart
	weld.Part1 = target
	armourPart.CFrame = target.CFrame
	weld.Enabled = true
	
	local player = IsPlayer(armourPart)
	if player then
		target.Transparency = 1
		
		if armourPart.Name == "Head" then
			for _, accessory in ipairs(player.Character:GetChildren()) do
				if accessory:IsA("Accessory") and accessory.AccessoryType == Enum.AccessoryType.Hair then
					local handle = accessory:FindFirstChild("Handle")
					if handle then
						handle.Transparency = 1
					end
				end
			end
		end
	end

	return weld
end

function module.UnweldParts(armourPart)
	if not armourPart then return end

	local weld = armourPart:FindFirstChild("_StandWeld")

	if not weld then return end
	weld.Enabled = false
	weld:Destroy()
	
	armourPart.Anchored = false
	
	local player = IsPlayer(armourPart)
	if player then
		armourPart.Parent.Transparency = 0
		
		if armourPart.Name == "Head" then
			for _, accessory in ipairs(player.Character:GetChildren()) do
				if accessory:IsA("Accessory") and accessory.AccessoryType == Enum.AccessoryType.Hair then
					local handle = accessory:FindFirstChild("Handle")
					if handle then
						handle.Transparency = 0
					end
				end
			end
		end
	end

	return weld
end

return module
