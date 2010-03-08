local M = delicious_class(delicious:get_class('delicious.base'), function(s, args)
	s:_base_init()
	s:set_module_name("delicious.util.image_cache")
	s.cache = {}
	s.image_path = awful.util.getdir("config") .. "/img/"
	s.badimg = widget({type = "imagebox"})
	s.badimg.image = image(s.image_path .. "delicious/invalid_image.png")
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
	self:debug("Get image: " .. path)
	local rpath = self.image_path .. path
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

