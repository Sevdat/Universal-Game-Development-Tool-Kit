local function GetTimeRemaining(text)
	local setting_15_Or_30 = text == "Legendary" and 30 or 15
	
	local now = DateTime.now().UnixTimestamp
	local intervalSeconds = setting_15_Or_30 * 60
	local remaining = intervalSeconds - (now % intervalSeconds)

	local minutes = math.floor(remaining / 60)
	local seconds = remaining % 60

	return "Guranteed "..text.." ".."in: "..string.format("%02d:%02d", minutes, seconds)
end

local frontFrame = script.Parent.SurfaceGui.Frame
local frontLegendary = frontFrame.LegendaryTimer
local frontMythic = frontFrame.MythicTimer

local backFrame = script.Parent.SurfaceGui1.Frame
local backLegendary = backFrame.LegendaryTimer
local backMythic = backFrame.MythicTimer


local function updateText()
	local legendary = GetTimeRemaining("Legendary")
	local mythic = GetTimeRemaining("Mythic")
	
	frontLegendary.Text = legendary
	frontMythic.Text = mythic
	
	backLegendary.Text = legendary
	backMythic.Text = mythic
end

local runservice = game:GetService("RunService")
local count = 0
runservice.Heartbeat:Connect(function(dt)
	count += dt
	if count < 1 then return end
	count = 0
	
	updateText()
end)