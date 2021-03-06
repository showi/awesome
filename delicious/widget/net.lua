local delicious_class = delicious_class
local delicious = delicious
local widget = widget
local beautiful = beautiful
local awful = awful
local string = string
setfenv(1, {})

local M = delicious_class(delicious:get_class("delicious.widget.base"), function(s, ...)
	s:_base_init("delicious.widget.net")
	s:set_parent(delicious)
	s.nif = arg[1].nif
	s.refresh = arg[1].refresh
	s.widgets = {
		label = widget({type = "textbox"}),
		text_down = widget({type = "textbox" }),
		icon_down = widget({type = "imagebox"}),
		text_up   = widget({type = "textbox" }),
		icon_up   = widget({type = "imagebox"}),
	}
	s.image_path = "delicious/widget/net/"
	s.theme = {
		width = 30,
        bg_color = beautiful.bg_normal,
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
        },  
        behavior = { 
            image_ratescaling = false,
        },
	}
	-- LABEL
	s.widgets.label.text = s.nif
	s.widgets.label.bg = s.theme.bg_color
	-- TEXT DOWN
	s.widgets.text_down.text = "000"
	local e = s.widgets.text_down:extents()
	s.widgets.text_down.width = e.width
	s.widgets.text_down.bg = s.theme.bg_color
	s.widgets.text_down.align = 'right' 
	s.widgets.icon_down.bg = s.theme.bg_color
	-- TEXT UP
	s.widgets.text_up.text = "000"
	e = s.widgets.text_up:extents()
	s.widgets.text_up.width = e.width
	s.widgets.text_up.bg = s.theme.bg_color
	s.widgets.text_up.width = 25
	s.widgets.text_up.align = 'left' 
	s.widgets.icon_up.bg = s.theme.bg_color
	
	s.widgets.icon_up.image   = 
		s:get_parent():get_image(s.image_path .. s.theme.images.up_kb)
	s.widgets.icon_down.image 
		= s:get_parent():get_image(s.image_path .. s.theme.images.down_kb)
	s.widgets.text_up.text = "n/a"
	s.widgets.text_down.text = "n/a"
	s:set_id_worker(s:get_parent().Workers:add('net', arg[1]))
	local w = s:get_parent():get_worker(s:get_id_worker())
	if not w.data[s.nif] then 
		s:warn("Invalid interface " .. s.nif .. " (You may check your configuration)")
	else
		w.data[s.nif].active = true	 
		w:add_listener('update', s)
	end
end)

function M:get_widgets()
	return {
		layout = awful.widget.layout.horizontal.rightleft,
		{	
			self.widgets.text_up, self.widgets.icon_up,
			layout = awful.widget.layout.horizontal.rightleft,
		},
		self.widgets.label,
		{
			self.widgets.icon_down, self.widgets.text_down,
			layout = awful.widget.layout.horizontal.rightleft,
		},
	}
end

local kilo = 1000
local mega = kilo * 1000
local giga = mega * 1000
function M:nicetx(data, interface, tx, p)
    if not p then -- p stand for precision 
        p = 1
    end
	local v = nil
	if tx == "up" then
		v = data[interface].up
	else 
		v = data[interface].down
	end
    if not v then
        return "b", "n/a"
    end
    if v >= giga then
        return "gb", string.format("%0."..p.."f", v / giga)
    elseif v >= mega then
        return "mb", string.format("%0."..p.."f", v / mega)
    elseif v >= kilo then
        return "kb", string.format("%0."..p.."f", v / kilo)
    else
        return "b", string.format("%0."..p.."f", v)
    end
end

function M:onupdate()
	if not self.parent then
		self:warn(self:get_module_name() .. " No parent, so no data")
		return false
	end
	local c = self:get_parent():get_worker(self:get_id_worker())
	if not c.data[self.nif] then
		self:warn("No data for interface "..self.nif.." (You may need to check your configuration)")
		return
	end
	if not c.data[self.nif].update then
		return false
	end
	do
		local u, v = self:nicetx(c.data, self.nif, 'up', 0)
		self.widgets.icon_up.image = 
			self:get_parent():get_image(self.image_path .. "up_" .. u .. ".png")
		self.widgets.text_up.text = v --or 'n/a'
	end
	do 
		local u, v = self:nicetx(c.data, self.nif, 'down', 0)
		self.widgets.icon_down.image = 
			self:get_parent():get_image(self.image_path .. "down_" .. u .. ".png")
		self.widgets.text_down.text = v --or 'n/a'
	end
	return true
end

return M
