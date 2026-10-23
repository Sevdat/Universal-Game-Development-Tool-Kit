local module = {}

local toolsModule = require(game:GetService("ReplicatedStorage"):FindFirstChild("Code"):FindFirstChild("CentralLink"))[1]

module.WaitingPlayer = {}
module._processing = false

function module:AddPlayer(player)
	table.insert(module.WaitingPlayer, player)
	self:ProcessQueue()
end

function module:ProcessQueue()
	if self._processing then return end
	self._processing = true

	while #self.WaitingPlayer > 0 do
		local player = table.remove(self.WaitingPlayer, 1)
		local ownedTycoon = toolsModule.GetData(player,{"Tycoon","OwnedTycoon"})
		
		for i, tycoon in ipairs(workspace.AllTycoons:GetChildren()) do
			local ownerUserId = tycoon:FindFirstChild("Values"):FindFirstChild("OwnerUserId")
			
			if ownerUserId and ownerUserId.Value == "" then
				ownerUserId.Value = tostring(player.UserId)
				ownedTycoon.Value = tycoon:GetAttribute("GUID")
				break
			end
		end
	end

	self._processing = false
end

function module.GiveArmour(player,armourPath)
	local stealerTycoonGUID = toolsModule.GetData(player,{"Tycoon","OwnedTycoon"}).Value
	local stealerTycoonTable = toolsModule.GetTool(stealerTycoonGUID)

	local armourTable = toolsModule.CreateTool(armourPath)

	stealerTycoonTable:InsertToArmourStand(armourTable.GUIDObject)

	return true
end

function module:RemovePlayer(player)
	local tycoonGUID = toolsModule.GetData(player,{"Tycoon","OwnedTycoon"}).Value
	local tycoonTable = toolsModule.GetTool(tycoonGUID)
	tycoonTable.OwnerUserId.Value = ""
end

return module
