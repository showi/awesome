local M = delicious_class(delicious:get_class('delicious.base'), function(s, ...)
	s:_base_init() 
	s:set_module_name("delicious.workers")
	s:set_parent(arg[1])
	s.workers = {}
	s.widget = widget({type = "textbox"})
end)


local function args_to_id(args) 
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
	local id = wtype .. ":".. args_to_id(args)
	local worker = self:get(id)
	if worker then return id end
	worker = self:set({
		id = id,
		refresh = args.refresh,
		wtype = wtype,
	})
	if wtype == "cpufreq" then
		self:debug("cpufreq: register vicious cpu: " .. args.cpu) 
		worker.register = vicious.register(self.widget, vicious.widgets.cpufreq,
			function(w, args)
				worker.args = args
				worker:emit('update', id)
			end, args.refresh, args.cpu)
	elseif wtype == "net" then 
		worker.register = vicious.register(self.widget, vicious.widgets.net,
			function(w, args)
				worker.args = args
				worker:emit('update', id)
			end, worker.refresh, worker.nif)
	elseif wtype == "weather" then 
		worker.register = vicious.register(self.widget, vicious.widgets.weather,
			function(w, args)
				worker.args = args
				worker:emit('update', id)
			end, args.refresh, args.station)
	end
	self:debug("Worker added: " .. id)
	return id
end


function M:set(args)
	local w = self:get(args.id)
	if w then
		self:warn("Worker with id " .. args.id .. " already set")
		return w
	end
	local Cworker = delicious:get_class("delicious.workers.one")
	if not self.workers[args.id] then
			self:debug("New " .. args.wtype .. " with " .. args.id)	
	end
	self.workers[args.id] = Cworker(self, args)
	return self.workers[args.id]
end

function M:get(id)
	if self.workers[id] then
		return self.workers[id]	
	end
	return nil
end

return M
