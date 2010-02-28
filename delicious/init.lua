-- Grab env
require("myfunc")
function trim(str)
	str = string.match(str, "^%s*(.*)$")
	str = string.match(str, "^(.*)%s*$")
	return str
end

-- Configure widgets
require("delicious.weather")



module("delicious")
