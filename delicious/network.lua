require("myfunc")

local M = {}
M.mt = {}

-- Variables
local img_dir = awful.util.getdir("config") .. "/img/"
local w_layout = awful.widget.layout.horizontal.rightleft

-- Icons
local icon_up = widget({type = "imagebox", layout = w_layout })
icon_up.image = image(img_dir .. "up.png")

local icon_down= widget({type = "imagebox", layout = w_layout})
icon_down.image = image(img_dir .. "down.png")

-- Helper function that display scaled network rate from bytes
local function nicetx(self, args, ifa, tx, p)
	print("self: " .. tostring(self))
	if not p then
		p = 1
	end
	
	local k = self.interface .. " " .. tx .. "_b"
	local kilo = 1000
	local mega = kilo * 1000
	local giga = mega * 1000
	local v = tonumber(args["{"..k.."}"])
	if not v then
		return "No data"
	end
	--v = math.random(0,1340992300)
	if not self.icon_up then self.icon_up = widget({type = "imagebox"}) end
	if not self.icon_down then self.icon_down = widget({type = "imagebox"}) end
	if v >= giga then	
		if tx == "up" then
			self.icon_up.image = image(img_dir .. self.theme.images.up_gb)
		else
			self.icon_down.image = image(img_dir .. self.theme.images.down_gb)
		end
		return string.format("%."..p.."fGB", v / giga)
	elseif v >= mega then
		if tx == "up" then
			self.icon_up.image = image(img_dir .. self.theme.images.up_mb)
		else
			self.icon_down.image = image(img_dir .. self.theme.images.down_mb)
		end
		return string.format("%."..p.."fMB", v / mega)
	elseif v >= kilo then
		if tx == "up" then
			self.icon_up.image = image(img_dir .. self.theme.images.up_kb)
		else
			self.icon_down.image = image(img_dir .. self.theme.images.down_kb)
		end
		return string.format("%."..p.."fkB", v / kilo)
	else
		if tx == "up" then
			self.icon_up.image = image(img_dir .. self.theme.images.up_b)
		else
			self.icon_down.image = image(img_dir .. self.theme.images.down_b)
		end
		return string.format("%."..p.."fb", v)
	end
end


-- Enable caching
vicious.enable_caching(vicious.widgets.net)


local function create_widget(self, param)
	print("self: " .. tostring(self))
	local w = widget({ type = "textbox", layout = self.layout})
	w.background_color = self.theme.background_color
	w.color = self.theme.color
	w.width = self.theme.width
	vicious.register(w, vicious.widgets.net,
    	function(widget, args)
			local img = nil
			local txt = nil
			if param == "up" then
    	    	return nicetx(self,args, self.interface, param, 1)
    	    elseif param == "down" then 
				return nicetx(self, args, self.interface, param, 1)
			else
				print("Error: invalid param " .. param)
				return
			end
		end, self.refresh)
	return w
end

local function create_tooltip(self, direction) 
	print("self: " .. tostring(self))
	local tooltip = awful.tooltip({
		obj = {k},
		timer_function = function()
			c = vicious.get_cache(vicious.widgets.net) -- get_cache is not in vicious 
			if c == nil then
				return "No data in cache"
			end
			str = ""
			if direction == "up" then
				str = "u: " .. nicetx(self, c.data, self.interface, "up", 3) .. "\n";
			else
				str = "d: " .. nicetx(self, c.data, self.interface, "down", 3) .. "\n";
			end
			str = str .. "rx: " .. nicetx(self, c.data, self.interface, "rx", 3) .. "\n";
			str = str .. "tx: " .. nicetx(self, c.data, self.interface, "tx", 3)
			return str
		end,
	})
	return tooltip
end

local function create_image(n)
	local i = widget({type = "imagebox", layout = w_layout})
	i.image = image(img_dir .. n)
	return i
end
local function get_widgets(self)
	print("self: " .. tostring(self))
	return { 
		self.up, self.icon_up, 
		self.down, self.icon_down, 
		layout = self.layout
	}
end

M.prototype = {
	interface = nil,
	refresh = 5,
	scale = true,
	unit = nil, -- not used
	layout = awful.widget.layout.horizontal.rightleft,
	icon_up = nil,
	icon_down = nil,
	theme = {
		width = 60,
		background_color = "#FF00",
		color = "#FFFFF",
		images = {
			down_b  = "down_b.png",
			down_kb = "down_kb.png",
			down_mb = "down_mb.png",
			down_gb = "down_gb.png",
			up_b    = "up_b.png",
			up_kb   = "up_kb.png",
			up_mb   = "up_mb.png",
			up_gb   = "up_gb.png",
		}
	}
	
}
M.mt = {}
M.new = function(interface, refresh)
	local self = {} 
	setmetatable(self, M.mt)
	self.interface = interface
	self.refresh = refresh
	self.tooltip = create_tooltip(self)
	local color = self.theme.background_color
	-- up
	self.theme.background_color = "#FF0000"
	self.up = create_widget(self, "up")
	self.tooltip:add_to_object(self.up)
	self.icon_up = create_image(self.theme.images.up_b)
	self.tooltip:add_to_object(self.icon_up)
	-- down
	self.theme.background_color = "#00FF00"
	self.down = create_widget(self, "down")
	self.tooltip:add_to_object(self.down)
	self.icon_down = create_image(self.theme.images.down_b)
	self.tooltip:add_to_object(self.icon_down)
	self.widgets = function() return get_widgets(self) end
	self.set_theme = function(t) self.theme = t end
	return self
end
M.mt.__index = function(table, key)
	return M.prototype[key]
end
return M
