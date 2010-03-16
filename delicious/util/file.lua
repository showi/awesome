local M = delicious_class(function(s, ...)
	s:_base_init("delicious.util.file")
end)

function M.file_exists(f)
	local h = io.open(f)
	if not h then return false end
	io.close(h)
	return true
end

function M.isdir(p)
	assert(p, "Cannot check for empty path")
	if os.execute("cd " .. p .. " >/dev/null 2>&1") == 0 then return true end
	return false
end

function M.isfile(f)
	if not M.file_exists(f) then return false end
	if M.isdir(f) then return false end
	return true
end

function M.isinpath(f)
	if not f then return false end
	if os.execute("which " .. f .. " >/dev/null 2>&1") == 0 then return true end
	return false
end

return M
