local M = delicious_class(delicious:get_class('delicious.workers.base'), function(s, ...)
	s:_base_init("delicious.workers.cpu")
	s.parent = arg[1]
	s.data = {
		total = { user = 0, nice =0, system=0, usage=0},
		cpu = {},
	}
	s.last_time = os.time()
	s:set_refresh(arg[2].refresh)
end)

function M:update(elapsed)
	local fcpu = "/proc/stat"
	local f = io.open(fcpu)
	if not f then
		self:warn("Cannot open file " .. fcpu)
		return
	end
	
	for line in f:lines() do
		local c = {}
		c.user, c.nice, c.system = string.match(line, "^%s*cpu%s+(%d+)%s+(%d+)%s(%d+).*$")
		if c.user then
				local u = ((c.user+c.system+c.nice) 
					- (self.data.total.user+self.data.total.nice+self.data.total.system)) / elapsed
				self.data.total.user = c.user
				self.data.total.nice = c.nice
				self.data.total.system = c.system
				self.data.total.usage = u
		end	
	end
	io.close(f)
	return true
end

return M
