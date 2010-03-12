local M = delicious_class(function(s, ...)
	s:_base_init("delicious.util.file")
end)

function M.file_exists(f)
	local h = io.open(f)
	if not h then return false end
	io.close(h)
	return true
end

return M
