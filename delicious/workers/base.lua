local M = delicious_class(delicious:get_class("delicious.base"), function(s, args)
end)

function M:set_refresh(refresh)
	self.refresh = refresh
end

function M:get_refresh()
	return self.refresh
end

function M:start()
	if self.timer then
		self.timer:stop()
	end
	self.timer = timer({ timeout = self.refresh })
	self.timer:add_signal("timeout", function() 
		local e = os.time() - self.last_time
		if e < 1 then e = 1 end
		self:update(e) 
		self.last_time = os.time()
	end)
	self.timer:start()
end

function M:stop()
	if self.timer then
		self.timer:stop()
		self.timer = nil
	end
end


return M
