local M = delicious_class(delicious:get_class("delicious.base"), function(s, ...)
	s:_base_init("delicious.fx.animation.controller")
	s.widget = arg[1]
	s.Animation = arg[2]
	s.time = os.time()
	s.index = 1
	s.timer = nil
	s.speed = 1
end)
	
function M:set_speed(speed)
	self.speed = speed
end

function M:get_speed(speed)
	return self.speed 
end

function M:start()
	self.index = 1
	local i = self.Animation:get_image(1)
	self.widget.image = i:get_image()
	self.timer = timer({ timeout = i.duration}) 
	self.timer:add_signal("timeout", function()
		if not self.Animation then return end 
		self.timer:stop()
		local i = self.Animation:get_image(self.index)
		if not i then
			self.index = 1
			i = self.Animation:get_image(self.index)
		end
		self.widget.image = i:get_image(i)
		self.index = self.index + 1
		self.timer.timeout = i.duration * self.speed
		self.timer:start()
	end)
	self.timer:start()
end

function M:stop()
	if not self.timer then
		return
	end
	self.timer:stop()
	self.timer = nil
end

function M:next()
	local d =  os.difftime(os.time(), self.time)
	if d > self.current.duration then
		local i = self.index + 1
		if not self.Animation.images[i] then
			if self.index == 0 then
				self:warn("Erreur: there's no image")
				return nil
			end
			self.index = 0
		end
		self.index = self.index + 1
		local i = self.Animation:get_image(self.index)
		self.widget.image = i:get_image(i)
		self.timer.timeout = i.duration * self.speed
		self.timer:start()
	end
end

return M

