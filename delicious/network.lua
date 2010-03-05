require("myfunc")

-- Enable caching
vicious.enable_caching(vicious.widgets.net)

local M = {}
M.mt = {}
M.cache = {}
M.prototype = {
	interface = nil,
	refresh = 5,
	scale = true,
	unit = nil, -- not used
	layout = awful.widget.layout.horizontal.rightleft,
	icon_up = nil,
	icon_down = nil,
	theme = {
		width = 21,
		background_color = "FF0000",
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

M._module_name = "delicious.network"

-- Variables
local img_dir = awful.util.getdir("config") .. "/img/"
local kilo = 1000
local mega = kilo * 1000
local giga = mega * 1000

-- Helper function that display scaled network rate from bytes
local function nicetx(self, args, interface, tx, p)
	if not p then -- p stand for precision 
		p = 1
	end
	local k = self.interface .. " " .. tx .. "_b"
	local v = tonumber(args["{"..k.."}"])
	if not v then
		return "b", "No data"
	end
	if v >= giga then	
		return "gb", string.format("%."..p.."f", v / giga) 
	elseif v >= mega then
		return "mb", string.format("%."..p.."f", v / mega) 
	elseif v >= kilo then
		return "kb", string.format("%."..p.."f", v / kilo) 
	else
		return "b", string.format("%."..p.."f", v) 
	end
end


-- change self.icon_up or self icon_down
local function set_icon(self, direction, unit)
	if direction ~= "up" and direction ~= "down" then
		print("Error: invalid direction '"..direction.."' (must be 'up' or 'down'")
		return
	end
	if self.icon_up and direction == "up" then
		if unit == "gb" then
			self.icon_up.image = M.get_image(self, self.theme.images.up_gb)
		elseif unit == "mb" then
			self.icon_up.image = M.get_image(self, self.theme.images.up_mb)
		elseif unit == "kb" then
			self.icon_up.image = M.get_image(self, self.theme.images.up_kb)
		else
			self.icon_up.image=  M.get_image(self, self.theme.images.up_b)
		end
	elseif self.icon_down and direction == "down" then
		if unit == "gb" then
			self.icon_down.image = M.get_image(self, self.theme.images.down_gb)
		elseif unit == "mb" then
			self.icon_down.image = M.get_image(self, self.theme.images.down_mb)
		elseif unit == "kb" then
			self.icon_down.image = M.get_image(self, self.theme.images.down_kb)
		else
			self.icon_down.image = M.get_image(self, self.theme.images.down_b)
		end
	else
		print("self.icon_[up|down] not set")
	end
end

-- Create text widget for network rate display
local function create_widget(self, direction)
	local w = widget({ type = "textbox", align = "right"})
	w.background_color = self.theme.background_color
	w.color = self.theme.color
	w.width = self.theme.width
	vicious.register(w, vicious.widgets.net,
    	function(widget, args)
			local unit, txt = nicetx(self, args, self.interface, direction, 0)
			set_icon(self, direction, unit)	
			return txt
		end, self.refresh)
	return w
end

-- Create tooltip
local function create_tooltip(self, direction) 
	local tooltip = awful.tooltip({
		obj = {k},
		timer_function = function()
			c = vicious.get_cache(vicious.widgets.net) -- get_cache is not in vicious 
			if c == nil then
				return M._module_name .. ": No data in cache"
			end
			local t, txt
			str = ""
			if direction == "up" then
				t, txt = nicetx(self, c.data, self.interface, "up", 3)
				str = "u: " .. txt.. t .."\n";
			else
				t, txt = nicetx(self, c.data, self.interface, "down", 3)
				str = "d: " .. txt .. t .."\n";
			end
			local rx, tx
			t, rx = nicetx(self, c.data, self.interface, "rx", 3)
			str = str .. "rx: " .. rx .. " " .. t .."\n";
			t, tx = nicetx(self, c.data, self.interface, "tx", 3)
			str = str .. "tx: " .. tx .. " " .. t 
			return str
		end,
	})
	return tooltip
end

-- Create image
local function create_image(self, n)
	local i = widget({type = "imagebox", layout = w_layout})
	if n then i.image = image(n) end
	i.width = 4 
	i.background_color = "FF0000"
	return i
end

M.set_image_cache = function(cache)
	M.cache = cache
end

M.get_image = function(self, path)
	return M.cache.get_image(path)
end

M.prototype.get_widgets = function(self)
	return { 
		self.up, self.icon_up, 
		self.down, self.icon_down, 
		layout = self.layout
	}
end


M.mt.__index = function(table, key)
	return M.prototype[key]
end

M.new = function(interface, refresh)
	local self = {} 
	setmetatable(self, M.mt)
	-- properties
	self.interface = interface
	self.refresh = refresh
	self.icon_up = nil
	self.icon_down = nil
	-- methods
	--self.get_image = function(self, path) return get_image(self, path) end
	self.create_image = function(self, path) return create_image(self, path) end
	self.set_theme = function(t) self.theme = t end
	-- constructing widgets
	self.tooltip_up   = create_tooltip(self, "up")
	self.tooltip_down = create_tooltip(self, "down")
	local color = self.theme.background_color
	-- up
	self.theme.background_color = "#FF0000"
	self.up = create_widget(self, "up")
	self.tooltip_up:add_to_object(self.up)
	self.icon_up = create_image(self, img_dir .. self.theme.images.up_b)
	self.tooltip_up:add_to_object(self.icon_up)
	-- down
	self.theme.background_color = "#00FF00"
	self.down = create_widget(self, "down")
	self.tooltip_down:add_to_object(self.down)
	self.icon_down = create_image(self, img_dir .. self.theme.images.down_b)
	self.tooltip_down:add_to_object(self.icon_down)
	return self
end

return M
