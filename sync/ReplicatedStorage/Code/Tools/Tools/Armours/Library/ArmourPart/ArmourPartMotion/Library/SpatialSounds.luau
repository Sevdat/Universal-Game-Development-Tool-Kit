local module = {}

local debris = game:GetService("Debris")

function module.Play3DSound(sound,parentPart)
	if not sound then return end
	
	local cloneSound = sound:Clone()
	cloneSound.Parent = parentPart or sound.Parent
	cloneSound:Play()

	debris:AddItem(cloneSound, cloneSound.TimeLength+1)
end

return module
