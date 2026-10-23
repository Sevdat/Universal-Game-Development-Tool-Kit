local runService = game:GetService("RunService")
local players = game:GetService("Players")


local cache = require(script.Cache)
local suffix = require(script.Suffix)

local gui = script.Parent.SurfaceGui
local background = gui.Background
local topDonaters = background.TopDonaters

local function update()
	local data = cache.UpdateTempCache()
	
	for i, donaterData in ipairs(data) do
		local donaterFrame = topDonaters:FindFirstChild(i)
		if donaterFrame then
			donaterFrame:FindFirstChild("Name").Text = donaterData.Name
			donaterFrame:FindFirstChild("Robux").Text = suffix.Shorten(donaterData.Amount)
		end
	end
end

local count = 10
runService.Heartbeat:Connect(function(dt)
	count -= dt
	if count <= 0 then
		count = 10
		update()
	end
end)