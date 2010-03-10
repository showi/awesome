local M = delicious_class(delicious:get_class('delicious.workers.base'), function(s, ...)
	s:_base_init("delicious.workers.cpufreq")
	s:set_debug(true)
	s:debug("New module [" .. s:get_module_name() .. "]")
	s.parent = arg[1]
	s.base_path = "/sys/devices/system/cpu"
	s.data = {}
	s.last_time = os.time()
	if not s:probe() then
		self:warn("Invalid probe")
	end
	s:set_refresh(arg[2].refresh)
end)

function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

function minmax(t)
	local min, max = nil
	for i, n in pairs(t) do
		if not min then
			min = n
		end
		if not max then
			max = n
		end
		if n > max then
			max = n	
		elseif n < min then
			min = n
		end
	end
	return min ,max
end
function M:probe()
	local f = io.popen("ls -la " .. self.base_path)
	if not f then
		self:warn("Cannot open " .. self.base_path)
		return false
	end
	for line in f:lines() do
		local m = string.match(line, "^.*cpu(%d+)$")
		if m then
			self.data[tonumber(m)] = {}
		end
	end
	io.close(f)
	for id, t in pairs(self.data) do
		local p_af = self.base_path .. "/cpu" .. id .. "/cpufreq/scaling_available_frequencies"
		f = io.open(p_af)
		if not f then
			self:warn("Cannot open file: " .. p_af)
		else
			self.data[id].available_frequencies = f:read():split(" ")
			for i, f in pairs(self.data[id].available_frequencies) do
				self.data[id].available_frequencies[i] = tonumber(f)
		 	end
			io.close(f)
			local min, max = minmax(self.data[id].available_frequencies)
	 		local step = math.floor((max - min) / 4)
			self.data[id].min = min
			self.data[id].max = max
	     	self.data[id].freq_steps = {}
			self.data[id].freq_steps[1] = min
			self.data[id].freq_steps[4] = max
			for i= 2,3 do
				self.data[id].freq_steps[i] = min + ((i-1) * step)
			end
		end
	end
	return true	
end


function M:update(elapsed)
	for id, t in pairs(self.data) do
		if not self:is_active(id) then
		else
			local file =  self.base_path .. "/cpu" .. id .. "/cpufreq/scaling_cur_freq"
			local f = io.open(file)
			if not f then	
				self:warn("Cannot read current frequency file: " .. file)
			else
				self.data[id].cur_freq = tonumber(f:read())
				io.close(f)
			end
		end
	end
end

return M
