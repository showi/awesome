local M = delicious_class(delicious:get_class('delicious.workers.base'), function(s, ...)
	s:_base_init("delicious.workers.net")
	s.parent = arg[1]
	s.data = {}
	s.last_time = os.time()
	s:set_refresh(arg[2].refresh)
end)

function M:update(elapsed)
	local f = io.open("/proc/net/dev")
	if not f then
		self:warn("Cannot open file /proc/net/dev")
		return
	end
	local change = false
	for line in f:lines() do
		--                                              name         rcv        2         3         4         5         6         7         8          9
		local name, rx, tx = string.match(line, "^[%s]*([%w]+):[%s]*([%d]+)[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+([%d]+).*$")
		if name then 
			rx = tonumber(rx)
			tx = tonumber(tx)
			if not self.data[name] then
				self.data[name] = { rx = rx, tx = tx, down = 0, up = 0, noupdate = 0}
			end
			local o = {
				rx = self.data[name].rx,
				tx = self.data[name].tx,
			}
			if self.data[name].rx == rx and
				self.data[name].tx == tx then
				if self.data[name].noupdate == 1 then
					self.data[name].update = true
					self.data[name].down = 0
					self.data[name].up   = 0
					change = true
				elseif self.data[name].noupdate == 2 then
					self.data[name].update = false
					self.data[name].down = 0
					self.data[name].up   = 0
				else
					self.data[name].noupdate = 0
					self.data[name].update = true
					change = true
				end
				self.data[name].noupdate = self.data[name].noupdate + 1
			else
				change = true
			
				self.data[name].rx = rx
				self.data[name].tx = tx
				self.data[name].noupdate = 0
				self.data[name].update = true
				self.data[name].down = (rx - o.rx) / elapsed  
				self.data[name].up   = (tx - o.tx) / elapsed  
			end
		end
	end
	io.close(f)
	return change	
end

return M
