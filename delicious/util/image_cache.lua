local img_dir =  awful.util.getdir("config") .. "/img/"
local invalid_image = widget({ type = "imagebox"})
invalid_image.image = image(img_dir .. "delicious/invalid_image.png")

local cbase = require("delicious.base")
local M = delicious_class(cbase, function(s, args)
	s:_base_init()
	s:set_module_name("delicious.util.image_cache")
	s.cache = {}
end)

function M:file_exists (n)
	local f = io.open(n)
	if f then 
		io.close(f)
		return true
	end
	return false
end

function M:get_image (path)
	local rpath = img_dir .. path
	if not self.cache[rpath] then
		self:debug("Trying to cache image: " .. rpath)
		if not self:file_exists(rpath) then
			self:warn("Error: invalid image path, " .. rpath)
			return invalid_image.image	
		end
		self.cache[rpath] = image(rpath)
	end
	return self.cache[rpath]	
end

return M

