local M = delicious_class(require("delicious.base_core"), function(s, args)
	s:set_module_name("delicious.base")
end)

function M:add_listener(event, _object)
	if not self.events then
		self.events = {}
	end
	if not self.events[event] then
		self.events[event] = {}
	end
	if not self.events[event][tostring(_object)] then
		self.events[event][_object] =  _object
	end
end

function M:emit(event, id)
	if not self.events then 
		self:warn("No events table")
		return 
	end
	if not self.events[event] then 
		self:warn("No entry for event " .. event)
		return 
	end
	for t, v in pairs(self.events[event]) do
		if event == "update" then
			if v and v.onupdate then 
				v:onupdate()
			end
		end
	end
end

return M
