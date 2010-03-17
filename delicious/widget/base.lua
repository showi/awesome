local delicious_class = delicious_class
local delicious = delicious
setfenv(1, {})

local M = delicious_class(delicious:get_class("delicious.base"), function(s, args)
end)

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
