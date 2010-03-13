local M = delicious_class(delicious:get_class('delicious.workers.base'), function(s, ...)
	s:_base_init("delicious.workers.net")
	s.parent = arg[1]
	s.data = s:fetch_data()
	for name in pairs(s.data) do
		s.data[name].active = false
	end
	s.last_time = os.time()
	s:set_refresh(arg[2].refresh)
end)

function M:fetch_data()
	local f = io.open("/proc/net/dev")
	if not f then
		self:warn("Cannot open file /proc/net/dev")
		return nil
	end
	local data = {}	
	for line in f:lines() do
		local name, rx, tx = string.match(line, "^[%s]*([%w]+):[%s]*([%d]+)[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+([%d]+).*$")
		if name then
			rx = math.floor(rx / 10) * 10
			tx = math.floor(tx / 10) * 10
			data[name] = {
				rx = tonumber(rx),
				tx = tonumber(tx),
			}
		end
	end
	io.close(f)
	--if #data < 1 then
	--	return nil
	--end
	return data
end

function M:update(elapsed)
	local f = io.open("/proc/net/dev")
	if not f then
		self:warn("Cannot open file /proc/net/dev")
		return false
	end
	local change = false
	local data = self:fetch_data()
	if not data then
		self:warn("Cannot access worker data")
		return false
	end
	for name,_ in pairs(data) do
		if self.data[name].active then 
			if not self.data[name] then
				self.data[name] = { rx = data[name].rx, tx = data[name].tx, down = 0, up = 0, noupdate = 0}
			end
			local o = {
				rx = self.data[name].rx,
				tx = self.data[name].tx,
			}
			if self.data[name].rx == data[name].rx and
			   self.data[name].tx == data[name].tx then
				local noupdate = self.data[name].noupdate
				local lochange = false
				if noupdate == 0 then
					noupdate = noupdate + 1
					lochange = true
				elseif noupdate == 1 then
					noupdate = noupdate + 1
					lochange = true
					self.data[name].down = 0	
					self.data[name].up   = 0	
				else
					lochange = false
				end	
				change = lochange
				self.data[name].noupdate = noupdate
			else
				change = true
				self.data[name].rx = data[name].rx
				self.data[name].tx = data[name].tx
				self.data[name].noupdate = 0
				self.data[name].update = true
				self.data[name].down = (data[name].rx - o.rx) / elapsed  
				self.data[name].up   = (data[name].tx - o.tx) / elapsed  
			end
		end	
	end
	io.close(f)
	return change	
end

return M
