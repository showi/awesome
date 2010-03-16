local M = delicious_class(function(s, args)
	s:set_module_name("delicious.base_core")
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
	local m = string.format("%10s", "[WARN][ " ..self:get_module_name() .. " ] " .. msg)
	self:log(m)
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
	self.parent = p
end

function M:get_parent()
	if self.parent then
		return self.parent
	end
	return M.parent
end

return M
