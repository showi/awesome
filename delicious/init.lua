print("init")
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
-- Setting image cache
local image_cache = require("delicious.util.image_cache")
-- Create module date
local M = {}
M.mt = {}
M.prototype = {}
-- Magic properties
M.mt.__index = function(t, k)
	return M.prototype[k]
end
-- Function to retrieve images cache
M.prototype.get_image_cache = function() 
	return image_cache
end
-- Loading modules
M.net     = require("delicious.network")
M.net.set_image_cache(image_cache)
M.cpufreq = require("delicious.cpufreq")
M.cpufreq.set_image_cache(image_cache)
M.weather = require("delicious.weather")
M.weather.set_image_cache(image_cache)
-- Set metatable to auto prototype accessing
setmetatable(M, M.mt)

return M
