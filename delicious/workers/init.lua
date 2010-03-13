local M = delicious_class(delicious:get_class('delicious.base'), function(s, ...)
	s:_base_init("delicious.workers") 
	s:set_parent(arg[1])
	s.workers = {}
	s.widget = widget({type = "textbox"})
end)

local function args_to_id(wtype, args) 
	if string.match(wtype, "^(net|cpufreq|cpu)$") then
		return wtype
	end
	local str = ""
	for t, v in pairs(args) do
		if t ~= "refresh" then
		local tv = type(v)
		if tv == "string" or tv == "number" then
			str = ":"..str .. v
		end	
		end
	end
	return str
end

function M:notify(id, ntype)
	if not self.workers[id] then
		self:warn("Error: invalid notify id")
		return
	end
	self:debug("Notify: " .. id)
	for k, v in pairs(self.workers[id].observers) do
		if v.onupdate then
			v:onupdate()
		end	
	end
end

function M:add(wtype, args)
	local id = args_to_id(wtype, args) 
	if not self.workers[id] then	
		self:debug("Add worker: " .. id)
		self.workers[id] = delicious:get_class("delicious.workers." .. wtype)(delicious, args)
		self.workers[id]:start()
	end
	return id
end

function M:get(id)
	if self.workers[id] then
		return self.workers[id]	
	end
	return nil
end

return M
