require('delicious.class')
local cbase = require("delicious.base")

local M = delicious_class(cbase, function(s, args)
	s.class = {}
	s.class['delicious.base'] = cbase
	s:_base_init()
	s.DEBUG = true
	s.widget = {}
	-- module init --
	s:set_module_name("delicious")
	s:debug("New module [" .. s:get_module_name() .. "]")
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

function M:list_modules()
	print("Listing loaded module(s)")
	for t, v in pairs(self.class) do
		print(" - " .. v:get_module_name())
	end
end

function M:load_modules(mtype, modules)
	for k, v in pairs(modules) do
		local mname = "delicious.widget." .. v
		--self:debug("Loading module "..mtype..": " .. mname)
		if mtype == "widget" then
			self.widget[v] = self:get_class(mname)
		end
	end	
end

delicious = M()
delicious:_init()
--return M
