local CollectionService = game:GetService("CollectionService")

local weapons = workspace.GunTest

for _, weapon in ipairs(weapons) do
	if weapon:IsDescendantOf(workspace) and weapon:IsA("Model") then
		-- Don't create duplicates
		local weldsFolder = Instance.new("Folder")
		weldsFolder.Name = "welds"
		weldsFolder.Parent = weapon

		local pivotCFrame =weapon:GetPivot()

		local rootPart = Instance.new("Part")
		rootPart.Name = "rootPart"
		rootPart.Size = Vector3.new(0.381, 0.606, 0.263)
		rootPart.Transparency = 1
		rootPart.CanCollide = false
		rootPart.CanTouch = false
		rootPart.CanQuery = false
		rootPart.Massless = true
		rootPart.Anchored = false
		rootPart.Position = pivotCFrame.Position
		rootPart.Parent = weapon

		local muzzle = Instance.new("Part")
		muzzle.Name = "Muzzle"
		muzzle.Size = Vector3.new(0.02, 0.066, 0.143)
		muzzle.Transparency = 1
		muzzle.CanCollide = false
		muzzle.CanTouch = false
		muzzle.CanQuery = false
		muzzle.Massless = true
		muzzle.Anchored = false
		muzzle.Position = pivotCFrame.Position
		muzzle.Parent = weapon

		local shootFrom =  Instance.new("Attachment")
		shootFrom.Name = "ShootFrom"
		shootFrom.Parent = muzzle

		for _, part in ipairs(weapon:GetDescendants()) do
			if part:IsA("BasePart") then
				if part ~= rootPart then
					local weld = Instance.new("WeldConstraint")
					weld.Part0 = rootPart
					weld.Part1 = part
					weld.Parent = weldsFolder

					part.Anchored = false
					part.CanCollide = false
					part.Massless = true
				else
					local weld = Instance.new("WeldConstraint")
					weld.Part0 = part
					weld.Parent = part
				end
			end
		end

	end
end