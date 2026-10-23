local WeaponGUI = {}
WeaponGUI.__index = WeaponGUI

local isClient = game:GetService("RunService"):IsClient()
local localPlayer = isClient and game.Players.LocalPlayer
local tweenService = game:GetService("TweenService")

function WeaponGUI.new()
	local self = setmetatable({}, WeaponGUI)
	
	self.HumanoidRootPart = nil
	
	self.WeaponBillboard = script.WeaponBillboard:Clone()
	self.Ammo = self.WeaponBillboard.Border.Border.Ammo
	
	self.WeaponBillboard.Parent = self.HumanoidRootPart
	
	self.Tween = nil

	return self
end

function WeaponGUI:Init(player,character)
	self.Player = player
	self.HumanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	self.WeaponBillboard = self.WeaponBillboard or script.WeaponBillboard:Clone()
	self.Ammo = self.Ammo or self.WeaponBillboard.Border.Border.Ammo
	self.WeaponBillboard.Parent = self.HumanoidRootPart
end

function WeaponGUI:Visible(on)
	if isClient and self.Player == localPlayer then 
		self.WeaponBillboard.Enabled = on
	end
end

function WeaponGUI:UpdateAmmo(ammo,maxAmmo)
	if isClient and self.Player == localPlayer then 
		if maxAmmo>0 then
			self.Ammo.Size = UDim2.new(1,0,ammo/maxAmmo,0)
		end
	end
end

function WeaponGUI:Reloading(reloadTime)
	if isClient and self.Player == localPlayer then 
		self:UpdateAmmo(0,1)
		
		if self.Tween and self.Tween.PlaybackState == Enum.PlaybackState.Playing then
			self.Tween:Cancel()
		end

		local tweenInfo = TweenInfo.new(reloadTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		self.Tween = tweenService:Create(self.Ammo, tweenInfo, {
			Size = UDim2.new(1, 0, 1, 0)
		})
		self.Tween:Play()
	end
end

function WeaponGUI:Destroy()
	self.Tween = self.Tween and self.Tween:Cancel()
	
	self.WeaponBillboard = self.WeaponBillboard and self.WeaponBillboard:Destroy()
	
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

return WeaponGUI
