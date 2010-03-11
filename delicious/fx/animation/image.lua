local M = delicious_class(delicious:get_class("delicious.base"), function(s, ...)
	s.path = arg[1]
	s.image = nil
	s.duration = arg[2]
	print("Adding image: " .. s.path)
	s.image = delicious.ImageCache:get_image(s.path)
end)

function M:get_image()
	return self.image
end

function M:get_duration()
	return self.duration
end

function M:set_duration(d)
	self.duration = d
end


return M

