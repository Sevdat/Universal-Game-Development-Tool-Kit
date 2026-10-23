local module = {}

module.GiveAura = function(model,rarity,despawnAuraTime)
	if not model then return end
	local attachParticleTo = {
		model:FindFirstChild("Head"),
		model:FindFirstChild("UpperTorso"),
		model:FindFirstChild("RightLowerLeg"),
		model:FindFirstChild("RightLowerArm"),
		model:FindFirstChild("LeftLowerLeg"),
		model:FindFirstChild("LeftLowerArm"),
	}

	for i,part in ipairs(attachParticleTo) do
		if not part then continue end
		local aura = script[rarity][part.Name]
		if not part then continue end

		aura = aura:Clone()
		aura.Parent = part

		if despawnAuraTime then
			debris:AddItem(aura,despawnAuraTime)
		end
	end
end

return module
