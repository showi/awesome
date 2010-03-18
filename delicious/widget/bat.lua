local delicious_class = delicious_class
local delicious = delicious
local widget = widget
local awful = awful
local beautiful = beautiful
local tostring = tostring
local print = print
setfenv(1, {})

local M = delicious_class(delicious:get_class('delicious.widget.base'), function(s, ...)
	s:_base_init("delicious.widget.bat")
	s:set_parent(delicious)
	s.id_worker = nil
	s.image_path = "delicious/widget/bat/"
	s.events = {}
	s.id    = arg[1].id or 1
	s.args = arg
	s:set_id_worker(s.parent.Workers:add('bat', arg[1]))
	s.widgets = { 
		icon = widget({type = "imagebox"}),
		layout = awful.widget.layout.horizontal.rightleft
	}
	s.widgets.icon.bg = beautiful.bg_normal
	s.widgets.icon.image = s.parent.ImageCache:get_image(s.image_path .. 
		s:get_battery_image("Unknown"))
	local w = s:get_parent():get_worker(s:get_id_worker())
	if not w.data[s.id] then
		s:warn("No data for battery " .. s.id .. " (You may check your configuration)")
	else
		s.widgets.icon.image = s.parent.ImageCache:get_image(s.image_path .. 
			s:get_battery_image(w.data[s.id].state, w.data[s.id].percent))
		w:add_listener('update', s)
	end
end)

function M:get_battery_image(state, percent)
	if state == "Full" then
		return "gpm-battery-charged.png"		
	elseif state == "Charging" then
		if percent >= 100 then
			return "gpm-battery-100-charging.png"		
		elseif percent >= 80 then
			return "gpm-battery-080-charging.png"		
		elseif percent >= 60 then
			return "gpm-battery-060-charging.png"		
		elseif percent >= 40 then
			return "gpm-battery-040-charging.png"		
		elseif percent >= 20 then
			return "gpm-battery-020-charging.png"		
		elseif percent >= 0 then
			return "gpm-battery-000-charging.png"		
		end	
	elseif state == "Discharging" then
		if percent >= 100 then
			return "gpm-battery-100.png"		
		elseif percent >= 80 then
			return "gpm-battery-080.png"		
		elseif percent >= 60 then
			return "gpm-battery-060.png"		
		elseif percent >= 40 then
			return "gpm-battery-040.png"		
		elseif percent >= 20 then
			return "gpm-battery-020.png"		
		elseif percent >= 0 then
			return "gpm-battery-000.png"		
		end	

	else
		return "gpm-battery-na.png"
	end
end

function M:onupdate()
	if not self:get_parent() then 
		self:warn(self:get_module_name() .. " No parent, so no data")
		return
	end
	local data = self:get_parent():get_worker(self:get_id_worker()).data[self.id]
	self.widgets.icon.image = self:get_parent():get_image(self.image_path
		.. self:get_battery_image(data.state, data.percent))
	return true
end

return M
