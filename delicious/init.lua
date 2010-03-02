-- Grab env
require("myfunc")

function trim(str)
	str = string.match(str, "^%s*(.*)$")
	str = string.match(str, "^(.*)%s*$")
	return str
end

-- Check that vicious is loaded
if not vicious then
    print("WARNING: You need vicious library to use delicious")
end

-- Configure widgets
require("delicious.weather")
require("delicious.cpufreq")


module("delicious")
