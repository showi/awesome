local string = string
local require = require
require('delicious.class')
local delicious_class = delicious_class
local setmetatable = setmetatable
local print = print
local setfenv = setfenv
local table = table
local _G = _G
setfenv(1, {})

function string:split(delimiter) -- must be moved 
  local result = { } 
  local from  = 1 
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) ) 
    from  = delim_to + 1 
    delim_from, delim_to = string.find( self, delimiter, from  )
  end 
  table.insert( result, string.sub( self, from  ) ) 
  return result
end

--[[ DELICIOUS
	There's only two global variable exported by this module
	- delicious namespace to access all delicious functionality
	- delicious_class function for creating new delicious class
--]]
local cbase = require("delicious.base")

local M = delicious_class(cbase, function(s, args)
	s.class = {} -- we store class to reuse it later
	s.class['delicious.base'] = cbase
	s.class['delicious.class'] = class 
	s:_base_init("delicious") -- Thing that all delicious module share
	s:set_debug(true) -- turn on/off debugging
	s.widget = {	
		mt = {
			__index = function(t, k) 
				return s:get_class("delicious.widget." .. k)
			end}
		}	
	setmetatable(s.widget, s.widget.mt) 
	s.fx = {
		mt = {
			__index = function(t, k) 
				return s:get_class("delicious.fx." .. k)
			end}
		}
	setmetatable(s.fx, s.fx.mt)
	s.string = {
		nltws = function(str)
			if not str then return nil end
			str = string.match(str, "^%s*(.*)$")	
			str = string.match(str, "^(.-)%s*$")
			return str
		end,
	} 
	s.parent = nil
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
		return self.class[n]
	end
	self:debug("Loading module " .. n)
	local m = require(n) 
	self.class[n] = m
	return self.class[n]
end

function M:get_image(n)
 	return self.ImageCache:get_image(n)
end

function M:get_worker(id)
	return self.Workers:get(id)
end

if _G.delicious then
	print("WARNING: delicious already defined")
else
	_G.delicious = M()
	_G.delicious:_init()
	setfenv(1, _G)
	--delicious = M()
	--delicious:_init()
end

return delicious
