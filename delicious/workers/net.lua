local M = delicious_class(delicious:get_class('delicious.workers.base'), function(s, ...)
	s:_base_init("delicious.workers.net")
	s:set_debug(true)
	s:debug("New module [" .. s:get_module_name() .. "]")
	s.parent = arg[1]
	s:set_refresh(arg[2].refresh)
	s.nif = {}
	s.last_time = os.time()
end)

function M:update(elapsed)
	print("Elapsed: " .. elapsed)
	local f = io.open("/proc/net/dev")
	if not f then
		self:warn("Cannot open file /proc/net/dev")
		return
	end
	for line in f:lines() do
		--                                              name         rcv        2         3         4         5         6         7         8          9
		local name, rx, tx = string.match(line, "^[%s]*([%w]+):[%s]*([%d]+)[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+[%d]+[%s]+([%d]+).*$")
		if name then 
			rx = tonumber(rx)
			tx = tonumber(tx)
			if not self.nif[name] then
				self.nif[name] = { rx = rx, tx = tx, down = 0, up = 0}
			end
			local o = {
				rx = self.nif[name].rx,
				tx = self.nif[name].tx,
			}
			self.nif[name].rx   = rx
			self.nif[name].tx   = tx
			self.nif[name].down = (rx - o.rx) / elapsed  
			self.nif[name].up   = (tx - o.tx) / elapsed  
			print("name: " .. name .. ", rx: " .. rx .. ", tx: " .. tx .. ", down: " .. self.nif[name].down .. ", up: " .. self.nif[name].up)
		end
	end	
end

return M
