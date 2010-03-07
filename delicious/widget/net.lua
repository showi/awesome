local cbase = require("delicious.widget.base")

local M = delicious_class(cbase, function(s, ...)
	s:_base_init()
	s:set_module_name("delicious.widget.net")
	s:set_parent(arg[1])
	s.widgets = {
		text_down = widget({type = "textbox" }),
		icon_down = widget({type = "imagebox"}),
		text_up   = widget({type = "textbox" }),
		icon_up   = widget({type = "imagebox"}),
		layout = awful.widget.layout.horizontal.rightleft,
	}
	--s.widgets.text_down.width = 40
	--s.widgets.icon_down.width = 8
	--s.widgets.text_up.width = 40
	--s.widgets.icon_up.width = 8
	s.nif = arg[2].nif
	s.refresh = arg[2].refresh
	print("if: " .. tostring(s.nif))
	print("refresh: " .. tostring(s.refresh))
	s.image_path = "delicious/widget/net/"
	s.theme = {
		width = 30,
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
        },  
        behavior = { 
            image_ratescaling = false,
        },
	}
	s.widgets.icon_up.image   = s.parent.ImageCache:get_image(s.image_path .. s.theme.images.up_kb)
	s.widgets.icon_down.image = s.parent.ImageCache:get_image(s.image_path .. s.theme.images.down_kb)
	s.widgets.text_up.text = "n/a"
	s.widgets.text_down.text = "n/a"

	s:set_id_worker(s.parent.Workers:add('net', arg[2]))
	local w = s:get_parent().Workers:get(s:get_id_worker())
	w:add_listener('update', s)
end)

function M:get_widgets()
	return {
		{
			self.widgets.icon_down, self.widgets.text_down,
			layout = awful.widget.layout.horizontal.rightleft,
			--width = 100
		},
		{	
			self.widgets.icon_up, self.widgets.text_up,
			layout = awful.widget.layout.horizontal.rightleft,
			--width = 100
		},
		width = 200,
		layout = awful.widget.layout.horizontal.rightleft,
	}
end
local kilo = 1000
local mega = kilo * 1000
local giga = mega * 1000
function M:nicetx(args, interface, tx, p)
    if not p then -- p stand for precision 
        p = 1
    end
    local k = interface .. " " .. tx .. "_b"
    local v = tonumber(args["{"..k.."}"])
    if not v then
        return "b", "n/a"
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

function M:onupdate()
	self:debug("Updating " .. self:get_module_name())
	if not self.parent then
		self:warn(self:get_module_name() .. " No parent, so no data")
		return
	end
	local c = self:get_parent().Workers:get(self:get_id_worker())
	do
		local u, v = self:nicetx(c.args, self.nif, 'up', 1)
		self.widgets.icon_up.image = 
			self:get_parent().ImageCache:get_image(self.image_path .. "up_" .. u .. ".png")
		self.widgets.text_up.text = v or 'n/a'
	end
	do 
		local u, v = self:nicetx(c.args, self.nif, 'down', 1)
		self.widgets.icon_down.image = 
			self:get_parent().ImageCache:get_image(self.image_path .. "down_" .. u .. ".png")
		self.widgets.text_down.text = v or 'n/a'
	end
end
return M
