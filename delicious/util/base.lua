local delicious_class = delicious_class
local delicious = delicious
local io = io
local print = print
local string = string
setfenv(1, {})

local M = delicious_class(delicious:get_class("delicious.base_core"), function(s, ...)

end)

function M:filetoarray(f)
	local h = io.open(f)
	if not h then
		self:warn("Cannot open file '"..f.."'")
		return
	end
	for line in h:line() do
		if line then
			print("line: " .. line)
		end:
	end
	io.close(h)
end

function M:sanestr(s)
	return string.format("%q", s)
end
return M
