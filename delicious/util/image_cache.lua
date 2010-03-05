local img_dir =  awful.util.getdir("config") .. "/img/"
local invalid_image = widget({ type = "imagebox"})
invalid_image.image = image(img_dir .. "delicious/invalid_image.png")
local M = {}
M.mt = {}
M.prototype = {
}
M.cache = {}

M.file_exists = function(n)
	local f = io.open(n)
	if f then 
		io.close(f)
		return true
	end
	return false
end

M.get_image = function (path)
	local rpath = img_dir .. path
	if not M.cache[rpath] then
		print("Trying to cache image: " .. rpath)
		if not M.file_exists(rpath) then
			print("Error: invalid image path, " .. rpath)
			return invalid_image.image	
		end
		M.cache[rpath] = image(rpath)
	end
	return M.cache[rpath]	
end

M._init = function(_s)
	
end

M.mt.__index = function(table, key)
    return M.prototype[key]
end

M.new = function(cpu, freq_list, refresh)
    local self = {}
    setmetatable(self, M.mt)
    self._init(self)
	return self
end

return M

