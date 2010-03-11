local M = delicious_class(function(s, args)
end)

function M:set_debug(b)
	self.DEBUG = b	
end

function M:get_debug()
	return self.DEBUG
end

function M:log(msg)
	print(msg)
end

function M:debug(msg)
	if (delicious and not delicious.DEBUG) or not self:get_debug() then 
		return
	end
	local m = string.format("%10s", "[DEBUG][ " ..self:get_module_name() .. " ] " .. msg)
	self:log(m)
end

function M:warn(msg)
	self:log("[WARN] " .. msg)
end

function M:_base_init(name)
	self._module = {
		name = name
	}
	self.DEBUG = true 
end

function M:set_module_name(n)
	self._module.name = n
end

function M:get_module_name()
	return self._module.name
end

function M:set_module_version(v)
	self._module.version = v
end

function M:get_module_version()
	return self._module.version
end

function M:set_parent(p)
	self:debug(self:get_module_name() .. " set parent")
	self.parent = p
end

function M:get_parent()
	if self.parent then
		return self.parent
	end
	return M.parent
end

function M:add_listener(event, _object)
	if not self.events then
		self.events = {}
	end
	if not self.events[event] then
		self.events[event] = {}
	end
	if not self.events[event][tostring(_object)] then
		self:debug(_object:get_module_name() .. " listen to our 'update' event")
		self.events[event][_object] =  _object
	end
end

function M:emit(event, id)
	self:debug("emit " .. event)
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
			self:debug("Update event")
			if v and v.onupdate then 
				v:onupdate()
			end
		end
	end
end

return M
