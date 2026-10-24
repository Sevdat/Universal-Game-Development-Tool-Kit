local module = {}

local debris = game:GetService("Debris")

function module.DestroyClientNPC(clientDummy)
	if not clientDummy then return end
	local humanoid = clientDummy:FindFirstChild("Humanoid")
	local delayDestruction = 0
	if humanoid then
		humanoid:Destroy()
		for _,e in ipairs(clientDummy:GetChildren()) do
			if e:IsA("BasePart") then
				e.CanCollide = true
				for _, joint in e:GetJoints() do
					joint:Destroy()
				end
				debris:AddItem(e,delayDestruction)
				delayDestruction +=0.1
			end
		end
	end
	debris:AddItem(clientDummy, 5)
end

return module
