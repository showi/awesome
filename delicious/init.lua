--[[ DELICIOUS
	There's only two global variable exported by this module
	- delicious namespace to access all delicious functionality
	- delicious_class function for creating new delicious class
--]]
require('delicious.class')
local cbase = require("delicious.base")

local M = delicious_class(cbase, function(s, args)
	s.class = {} -- we store class to reuse it later
	s.class['delicious.base'] = cbase
	s.class['delicious.class'] = class 
	s:_base_init() -- Thing that all delicious module share
	s:set_module_name("delicious")
	s:set_debug(true) -- turn on/off debugging
	s.widget = {	
		mt = {
			__index = function(t, k) 
				return s:get_class("delicious.widget." .. k)
			end
		}
	}
	setmetatable(s.widget, s.widget.mt) 
	s.parent = nil
	s:debug('Image cache: ' .. tostring(s.ImageCache))
end)

function M:_init()
	self.ImageCache = self:get_class('delicious.util.image_cache')(self)
	self.Workers    = self:get_class('delicious.workers')(self)
end
-- overide base class
function M:set_parent()
	set_parent = nil
	self:warn("Error: cannot set parent for delicious (set to nil)")
	return
end

-- overide base class
function M:set_module_name()
end
function M:get_module_name()
	return "delicious"
end

function M:get_class(n)
	if self.class[n] then
		self:debug("Return delicious class " .. n)
		return self.class[n]
	end
	self:debug("Creating and return class " .. n)
	self.class[n] = require(n)
	return self.class[n]
end

-- Function to retrieve images cache
function M:get_image_cache()
	return self.ImageCache
end

function M:get_worker_id(id)
	return self.Workers:get(id)
end

function M:set_id_worker(id)
	self.id_worker = id
end

function M:get_id_worker(id)
	return self.id_worker
end

delicious = M()
delicious:_init()
--return M
