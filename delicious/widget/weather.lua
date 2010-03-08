local cbase = require("delicious.widget.base")

local M = delicious_class(cbase, function(s, ...)
	s:_base_init()
	s:set_module_name("delicious.widget.weather")
	s:set_parent(delicious)
	s.station = arg[1].station
	s.refresh = arg[1].refresh
	s.widgets = {
		label = widget({type = "textbox"}),
		text_down = widget({type = "textbox" }),
		icon_down = widget({type = "imagebox"}),
		text_up   = widget({type = "textbox" }),
		icon_up   = widget({type = "imagebox"}),
	}
	s.image_path = "delicious/widget/weather/"
	s.theme = {
		width = 30,
        bg_color = beautiful.bg_focus,
        color = "#FFFFF",
        images = { 
        },  
	}
	s:set_id_worker(s.parent.Workers:add('weather', arg[1]))
	local w = s:get_parent().Workers:get(s:get_id_worker())
	w:add_listener('update', s)
end)

function M:onupdate()
	self:debug("Updating " .. self:get_module_name())
	if not self.parent then
		self:warn(self:get_module_name() .. " No parent, so no data")
		return
	end
	local c = self:get_parent().Workers:get(self:get_id_worker())
end
return M
