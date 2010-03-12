local _module_name = "delicious.base"
local class = require("delicious.base_core")
local M = delicious_class(class, function(s, args)
	s:set_module_name(_module_name)
end)


function M:add_listener(event, _object)
	if not self.events then
		self.events = {}
	end
	if not self.events[event] then
		self.events[event] = {}
	end
	if not self.events[event][tostring(_object)] then
	--	self:debug(_object:get_module_name() .. " listen to our 'update' event")
		self.events[event][_object] =  _object
	end
end

function M:emit(event, id)
	--self:debug("emit " .. event)
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
			--self:debug("Update event")
			if v and v.onupdate then 
				v:onupdate()
			end
		end
	end
end

return M
