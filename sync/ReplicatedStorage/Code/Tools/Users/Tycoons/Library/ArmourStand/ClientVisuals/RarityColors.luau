local module = {}

local tweenService = game:GetService("TweenService")

local color = {
	Empty = {
		First = Color3.fromRGB(165, 165, 165),
		Second = Color3.fromRGB(165, 165, 165),
		Third = Color3.fromRGB(248, 248, 248),
		Fourth = Color3.fromRGB(237, 234, 234)
	},
	Common = {
		First = Color3.fromRGB(0, 255, 0),
		Second = Color3.fromRGB(31, 128, 29),
		Third = Color3.fromRGB(58, 125, 21),
		Fourth = Color3.fromRGB(44, 101, 29)
	},
	Rare = {
		First = Color3.fromRGB(9, 137, 207),
		Second = Color3.fromRGB(13, 105, 172),
		Third = Color3.fromRGB(9, 137, 207),
		Fourth = Color3.fromRGB(82, 124, 174)
	},
	Epic = {
		First = Color3.fromRGB(255, 0, 191),
		Second = Color3.fromRGB(167, 0, 131),
		Third = Color3.fromRGB(136, 0, 107),
		Fourth = Color3.fromRGB(123, 47, 123)
	},
	Mythic = {
		First = Color3.fromRGB(196, 40, 28),
		Second = Color3.fromRGB(151, 0, 0),
		Third = Color3.fromRGB(255, 0, 0),
		Fourth = Color3.fromRGB(196, 40, 28)
	},
	Legendary = {
		First = Color3.fromRGB(255, 255, 0),
		Second = Color3.fromRGB(172, 118, 0),
		Third = Color3.fromRGB(239, 181, 44),
		Fourth = Color3.fromRGB(255, 176, 0)
	}
}

local m1 = 2.5
local t1,t2,t3,t4 = 0,0,0,0
local r1,r2,r3,r4 = 0,0,0,0

local order = {{"First",m1,t1}, {"Second",m1,t2}, {"Third",m1,t3}, {"Fourth",m1,t4}}
local orderReversed = {{"Fourth",m1,r1},{"Third",m1,r2}, {"Second",m1,r3}, {"First",m1,r4}}

function module.Recolor(armourStandTable, rarity,reverse)
	local rarityColors = color[rarity]

	local tweens = {}

	for i, getTable in ipairs(reverse and orderReversed or order) do
		local name = getTable[1]
		local duration = getTable[2]
		local delayTime = getTable[3]

		local tweenInfo = TweenInfo.new(
			duration,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out,
			0,
			false,
			delayTime
		)
		
		local part = armourStandTable[name]
		if part then
			local tween = tweenService:Create(part, tweenInfo, {
				Color = rarityColors[name]
			})

			tween:Play()
			table.insert(tweens, tween)
		end
	end

	return function()
		for _, tween in ipairs(tweens) do
			tween:Cancel()
		end
	end
end

return module
