local M = {}
M.mt = {}
M.prototype = {
	name = nil,
	index = 1,
	--Images = {},
	prefix = "",
}
-- Composition
M.factory = {}
M.factory.Controller = require("delicious.fx.animation.controller")
M.factory.Image = require("delicious.fx.animation.image")

M.cache = nil
-- Getters/Setters
M.prototype.set_prefix = function(_s, prefix)
	_s.prefix  = prefix
end
M.prototype.get_prefix = function(_s, prefix)
	return _s.prefix
end

-- Adding image to animation
M.prototype.add_image = function(_s, path, duration)
	if not duration then duration = 1 end
	local rpath = _s.prefix .. path
	--print("add image: " .. rpath)
	if not M.cache then
		print("Error: delicious.animation.cache nil cache")
		return
	end 
	local i = M.factory.Image.new(rpath, duration)
	_s.Images[_s.index] = i
	_s.index = _s.index + 1
end

-- Getting a controler 
M.prototype.get_controller = function(_widget, _animation)
	return M.factory.Controller.new(_widget, _animation)
end

M.prototype.get_image = function(_s, i)
	if _s.Images then return _s.Images[i] end
	print ("no image to return")
	return nil
end

M.set_image_cache = function(cache)
	M.cache = cache
	M.factory.Image.set_image_cache(cache)
end

M.fromdir = function(path, name, max, refresh) 
	local a = M.new(name)
	for i = 0, max do
		local ipath = path .. name .. "-" .. i .. ".png", refresh
		a.add_image(a, ipath, refresh)
	end
	return a
end
M.new = function(name)
    local self = {}
    setmetatable(self, M.mt)
   	self.name = name
	--self.cache = cache
	self.Images = {}
	return self
end

M.mt.__index = function(table, key)
    return M.prototype[key]
end

return M
