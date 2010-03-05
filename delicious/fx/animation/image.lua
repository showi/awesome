local img_dir = awful.util.getdir("config") .. "/img/"
local M = {}
M.mt = {}
M.prototype = {
	path = "",
	image = nil,
	duration = nil
}
M.cache = {}

M.set_image_cache = function (cache)
	print("Image module: setting image cache")
	M.cache = cache
end

M.prototype.get_image = function(_s) --, path)
	return _s.image -- M.cache.get_image(path)
end


M.new = function(path, duration)
	local self = {
	--	cache = cache
	}
    setmetatable(self, M.mt)
    --self.path = path
    self.duration = duration
	--print("New image: " .. path .. ", " .. duration)
	self.image = M.cache.get_image(path)
	return self
end

M.mt.__index = function(table, key)
    return M.prototype[key]
end

return M

