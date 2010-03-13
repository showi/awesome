local M = delicious_class(delicious:get_class("delicious.base"), function(s, args)
	s._base_init__parent = s._base_init
	s.base_init = function(self)
		self:base_init__parent()
		print("init:  " .. self:get_module_name())
	end
end)

function M:set_refresh(refresh)
	self.refresh = refresh
	self:stop()
	self:start()
end

function M:get_refresh()
	return self.refresh
end

function M:start()
	if self.timer then
		self.timer:stop()
	end
	self:update(1)
	self.timer = timer({ timeout = self.refresh })
	self.timer:add_signal("timeout", function() 
		local e = os.time() - self.last_time
		if e < 1 then e = 1 end
		if self:update(e) then
			self:emit('update') 
		end
		self.last_time = os.time()
	end)
	self.timer:start()
end

function M:set_active(id)
	self.data[id].active = true
end

function M:set_inactive(id)
	self.data[id].active = false
end

function M:is_active(id)
	return self.data[id].active
end

function M:stop()
	if self.timer then
		self.timer:stop()
		self.timer = nil
	end
end


return M
