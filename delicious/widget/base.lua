local cbase = require("delicious.base")
local M = delicious_class(cbase, function(s, args)

end)

--function M:set_parent(p) 
--	self.parent = p
--end
--
--function M:get_parent(p)
--	return self.parent
--end

function M:set_id_worker(id)
	self.id_worker = id
end

function M:get_id_worker()
	return self.id_worker
end

function M:get_widgets()
	return self.widgets
end

return M
