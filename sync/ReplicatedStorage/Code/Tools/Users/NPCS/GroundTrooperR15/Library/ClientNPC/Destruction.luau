local module = {}

local debris = game:GetService("Debris")

function module.DestroyClientNPC(clientDummy)
	if not clientDummy then return end
	for _,e in ipairs(clientDummy:GetChildren()) do
		if e:IsA("BasePart") then
			e.CanCollide = true
			for _, joint in e:GetJoints() do
				joint:Destroy()
			end
		end
	end
	debris:AddItem(clientDummy, 5)
end

return module
