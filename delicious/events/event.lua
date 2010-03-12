local M = delicious_class(function(s, ...)
	s.src = nil
	s.target = nil
	s.func = nil
end)
local mt = {
	__index = function(t, k, arg)
		local m, f = string.match(k, "^(get|set)_(.*)")
		if not m then
			print("Can only use method like get_foo or set_bar(foo)")
			return nil
		end
		if m == "get" then
			return t[k]
		else
			t[k] = arg 
		end
	end
}
return M
