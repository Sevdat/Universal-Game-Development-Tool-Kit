local module = {}

--https://github.com/berezaa/minershaven/blob/master/src/ReplicatedStorage/MoneyLib.lua

local suffixes = {
	"k","M","B",
	"T","qd","Qn",
	"sx","Sp","O",
	"N","de","Ud","DD",
	"tdD","qdD","QnD",
	"sxD","SpD","OcD",
	"NvD","Vgn","UVg",
	"DVg","TVg","qtV",
	"QnV","SeV","SPG",
	"OVG","NVG","TGN",
	"UTG","DTG","tsTG",
	"qtTG","QnTG","ssTG",
	"SpTG","OcTG","NoTG",
	"QdDR","uQDR","dQDR",
	"tQDR","qdQDR","QnQDR",
	"sxQDR","SpQDR","OQDDr",
	"NQDDr","qQGNT","uQGNT",
	"dQGNT","tQGNT","qdQGNT",
	"QnQGNT","sxQGNT","SpQGNT",
	"OQQGNT","NQQGNT","SXGNTL"
}

function module.Shorten(number)
	if number == 0 then return "$0" end

	local absInput = math.abs(number)

	local index = math.floor(math.log10(absInput) / 3)

	if index < 1 then
		return "$" .. string.format("%d", number)
	end

	index = math.min(index, #suffixes)

	local shortVal = number / (10 ^ (index * 3))

	local formatted = string.format("%.2f", shortVal):sub(1, 4):gsub("%.+$", "")

	return "$" .. formatted .. suffixes[index]
end

return module
