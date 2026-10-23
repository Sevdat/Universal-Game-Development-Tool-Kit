return function(str)
	local hash = 5381
	for i = 1, #str do
		hash = (hash * 33 + string.byte(str, i)) % 4294967296
	end
	return hash
end
