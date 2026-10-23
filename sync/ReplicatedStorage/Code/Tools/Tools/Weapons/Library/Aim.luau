local module = {}

module.Aim = {}

function module.CanUpdate(userGuidObject:StringValue)
	local aimData = module.Aim[userGuidObject.Value] or module.Update(userGuidObject,Vector3.zero,nil)

	return workspace:GetServerTimeNow() - aimData.LastUpdated > 0.1
end

function module.Update(userGuidObject:StringValue,position:Vector3,target:BasePart)
	module.Aim[userGuidObject.Value] = {
		Position = position,
		Target = target,
		LastUpdated = workspace:GetServerTimeNow()
	}
	
	return module.Aim[userGuidObject.Value]
end

function module.Get(userGuidObject:StringValue)
	local aimData = userGuidObject and module.Aim[userGuidObject.Value]
	if not aimData then return nil,nil end
	
	return aimData.Position, aimData.Target
end

function module.Remove(userGuidObject:StringValue)
	if userGuidObject then
		module.Aim[userGuidObject.Value] = nil
	end
end

return module
