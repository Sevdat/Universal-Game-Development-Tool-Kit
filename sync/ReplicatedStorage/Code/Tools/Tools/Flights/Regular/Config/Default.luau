local function attachParticle(character,particle,bodyPartName)
	if not character or not particle then return end

	local bodyPart = character:FindFirstChild(bodyPartName)
	if not bodyPart then return end

	local particleClone = particle:Clone()

	particleClone.Parent = bodyPart
	
	particleClone.Position = Vector3.zero
	particleClone.Orientation = Vector3.zero

	return particleClone
end


return {
	ConfigName = script.Name,
	
	Drag = 1,
	FlightForce = 1200,

	FlyIdle = script.FlyIdle,
	FlyLeft = script.FlyLeft,
	FlyRight = script.FlyRight,
	FlyForward = script.FlyForward,
	FlyBackward = script.FlyBackward,
	
	ParticleEffect = script.Attachment,
	
	InitParticles = function(self,character)
		local particle = self.ParticleEffect
		return {
			RightHand = attachParticle(character,particle,"RightHand"),
			LeftHand = attachParticle(character,particle,"LeftHand"),
			RightFoot = attachParticle(character,particle,"RightFoot"),
			LeftFoot = attachParticle(character,particle,"LeftFoot"),
			
			Activate = function(self,active)
				local bodyparts = {self.RightHand,self.LeftHand,self.RightFoot,self.LeftFoot}
				for i,bodypart in bodyparts do
					local particleEmitter = bodypart:FindFirstChildOfClass("ParticleEmitter")
					if particleEmitter then
						particleEmitter.Enabled = active
					end
				end		
			end,
			
			Destroy = function(self)
				self.RightHand:Destroy()
				self.LeftHand:Destroy()
				self.RightFoot:Destroy()
				self.LeftFoot:Destroy()
			end,
		}
	end,
}