local module = {}

function module.MovementLogicClient(activeClientHRP,humanoid,alignOrientation,hitbox,targetHRP,IdleAnimationTrack,RunAnimationTrack,Scale)
	if activeClientHRP and activeClientHRP.Parent then
		local distance = (hitbox.Position - activeClientHRP.Position).Magnitude
		if distance > 4 then
			humanoid:MoveTo(hitbox.Position)
		else
			humanoid:MoveTo(activeClientHRP.Position) 
		end
		
		if targetHRP then
			alignOrientation.LookAtPosition = Vector3.new(
				targetHRP.Position.X,
				activeClientHRP.Position.Y, 
				targetHRP.Position.Z
			)
		end

		if distance > 5 then
			IdleAnimationTrack:Stop()
			if not RunAnimationTrack.IsPlaying then
				RunAnimationTrack:Play()
			end
		else
			RunAnimationTrack:Stop()
			if not IdleAnimationTrack.IsPlaying then
				IdleAnimationTrack:Play()
			end
		end
	end
	alignOrientation.Enabled = true
end

return module
