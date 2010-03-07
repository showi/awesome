require('delicious.class')
local cbase = require("delicious.base")

local M = delicious_class(cbase, function(s, args)
	s:_base_init()
	-- module init --
	s:set_module_name("delicious")
	s:debug("New module [" .. s:get_module_name() .. "]")
	s.parent = nil
	local CImageCache = require("delicious.util.image_cache")
	s.ImageCache = CImageCache(s)
	local CWorkers = require("delicious.workers")
	s.Workers = CWorkers(s) 
	s.widget = {}
	s.modules = {}
	s:debug('Image cache: ' .. tostring(s.ImageCache))
end)

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
	for t, v in pairs(self.widget) do
		print(" - " .. v:get_module_name())
	end
end

function M:load_modules(mtype, modules)
	for k, v in pairs(modules) do
		local mname = "delicious.widget." .. v
		if self.modules[v] then
			self:warn("Module '"..mname.."' already loaded")
		end
		self:debug("Loading module: " .. mname)
		if mtype == "widget" then
			self.widget[v] = require(mname)
		end
	end	
end

return M
