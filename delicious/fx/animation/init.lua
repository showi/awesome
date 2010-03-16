local M = delicious_class(delicious:get_class('delicious.base'), function(s, ...)
	s:_base_init("delicious.fx.animation")
	s.name = arg[1]
	s.index = 1
	s.prefix = arg[2].prefix
	s.images = {}
	s.animation_path = "delicious/animation/"
	if arg[2] and arg[2].autoload then
		s:load_from_dir()	
	end
end)

function M:make_path(i) 
	return self.animation_path .. self.prefix .. self.name .. "/" .. self.name .. "-" .. i .. ".png"
end

function M:load_from_dir()
	local util = delicious:get_class("delicious.util.file")
	local i = 0
	local imgpath = self:make_path(i)
	while imgpath and util.file_exists(delicious.ImageCache:get_path() .. imgpath) do
		self:insert_image(imgpath, 1)
		i = i + 1
		imgpath = self:make_path(i)
	end
	if i > 0 then
		return true
	end
	self:warn("No image added from directory " .. self.name)
	return false
end

-- Getters/Setters
function M:set_prefix(prefix)
	self.prefix  = prefix
end

function M:get_prefix(prefix)
	return self.prefix
end

function M:insert_image(path, duration)
	util = delicious:get_class("delicious.util.file")
	if not util.file_exists(delicious.ImageCache:get_path() .. path) then
		self:warn("Cannot add image to animation (invalid file)")
		return false
	end
	self.images[self.index] = delicious:get_class("delicious.fx.animation.image")(path, duration)
	self.index = self.index + 1
	return true
end

-- Getting a controler 
function M:get_controller(_widget)
	return delicious:get_class("delicious.fx.animation.controller")(_widget, self)
end

function M:get_image(i)
	if self.images then return self.images[i] end
	self:warn("There's no image at index " .. i)
	return nil
end

function M:fromdir(path, name, max, refresh) 
	local a = M.new(name)
	for i = 0, max do
		local ipath = path .. name .. "-" .. i .. ".png", refresh
		a.add_image(a, ipath, refresh)
	end
	return a
end

return M
