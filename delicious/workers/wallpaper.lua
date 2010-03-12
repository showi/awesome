local M = delicious_class(delicious:get_class('delicious.workers.base'), function(s, ...)
	s:_base_init("delicious.workers.wallpaper")
	s.parent = arg[1]
	s.data = {}
	s.last_time = os.time()
	s:set_refresh(arg[2].refresh)
end)

function M:update(elapsed)
	local cmd = "/usr/local/bin/awsetbg -f -r " .. self:get_parent().ImageCache:get_path() .."delicious/wallpapers/ &"
	print("Cmd: " .. cmd)
	os.execute(cmd)
end

return M
