local M = delicious_class(delicious:get_class("delicious.base_core"), function(s, ...)
end)

function M.notkeys(t, tkeys)
	if not t then return nil end
	local dtable = {}
	for _, k in pairs(t) do
		local keep = true
		for _, nk in pairs(tkeys) do
			if nk == k then 
				keep = false
				break
			end
		end 
		if keep then 
			table.insert(dtable, k)
		end
	end
	return dtable
end

return M
