local tween = require(script.Parent.Tween)
local rarityColors = require(script.RarityColors)
local spatialSounds = require(script.Parent.SpatialSounds)
local isClient = game:GetService("RunService"):IsClient()

local ClientVisuals = {}
ClientVisuals.__index = ClientVisuals

function ClientVisuals.new(armourStand)
	local self = setmetatable({}, ClientVisuals)

	self.TycoonOwner = nil

	local decoration = armourStand.Stand.Decoration
	self.First = decoration.First
	self.Second = decoration.Second
	self.Third = decoration.Third
	self.Fourth = decoration.Fourth
	
	self.StopColorTween = function() end
	
	return self
end

function ClientVisuals:Init(tycoonOwner)
	self.TycoonOwner = tycoonOwner
end

function ClientVisuals:ChangeColor(added:boolean,rarity:string)
	if isClient then
		if added then
			self.StopColorTween()
			self.StopColorTween = rarityColors.Recolor(self,rarity,false)
		else
			self.StopColorTween()
			self.StopColorTween = rarityColors.Recolor(self,"Empty",true)
		end
	end
end

function ClientVisuals:Destroy()
	self.First = nil
	self.Second = nil
	self.Third = nil
	self.Fourth = nil
	
	self.StopColorTween()
	self.StopColorTween = nil

	table.clear(self)
	setmetatable(self, nil)
end

return ClientVisuals