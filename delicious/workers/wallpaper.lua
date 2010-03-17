local delicious = delicious
local delicious_class = delicious_class
local os = os
setfenv(1, {})

local M = delicious_class(delicious:get_class('delicious.workers.base'), function(s, ...)
	s:_base_init("delicious.workers.wallpaper")
	s.parent = arg[1]
	s.bin_awsetbg = "/usr/local/bin/awsetbg"
	s.data = {}
	s.last_time = os.time()
	s:set_refresh(arg[2].refresh)
end)

function M:update(elapsed)
	if os.execute(
		self.bin_awsetbg .. " -f -r " 
		.. self:get_parent().ImageCache:get_path() .."delicious/wallpapers/ &") ~= 0 then
		s:warn("Cannot change wallpaper using " .. bin_awsetbg)
	end
	return false
end

return M
