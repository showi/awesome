local M = delicious_class(function(s, args)
end)

function M:log(msg)
	print(msg)
end

function M:debug(msg)
	self:log("[DEBUG] " .. msg)
end

function M:warn(msg)
	self:log("[WARN] " .. msg)
end

function M:_base_init()
	self._module = {}
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
		self:debug("Add listener('" .. event .. "'): " .. tostring(_object))
		self.events[event][_object] =  { o = _object}
	end
end
function M:emit(event, id)
	self:debug("emit " .. event .. " ["..id .."]")
	if not self.events then 
		self:warn("No events table")
		return 
	end
	if not self.events[event] then 
		self:warn("No entry for event " .. event)
		return 
	end
	for t, v in pairs(self.events[event]) do
		--print("t, v: " .. tostring(t) .. ", " .. tostring(v))
		if event == "update" then
			self:debug("Update event")
		if v.o and v.o.onupdate then 
			v.o:onupdate()
		end
	end
	end
end

return M