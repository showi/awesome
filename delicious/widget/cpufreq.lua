local M = delicious_class(delicious:get_class('delicious.widget.base'), function(s, ...)
	s:_base_init("delicious.widget.cpufreq")
	s:set_parent(delicious)
	s.id_worker = nil
	s.image_path = "delicious/widget/cpufreq/"
	s.events = {}
	s.id    = arg[1].id
    s.cpu   = arg[1].cpu
	s.args = arg
	s:debug("cpu: " .. arg[1].cpu)
	s:set_id_worker(s.parent.Workers:add('cpufreq', arg[1]))
	s:debug("Id worker: " .. s:get_id_worker())
	s.widgets = { 
		icon = widget({type = "imagebox"}),
		layout = awful.widget.layout.horizontal.rightleft
	}
	s.widgets.icon.bg = beautiful.bg_focus
	s.widgets.icon.image = s.parent.ImageCache:get_image(s.image_path .. "na.png")
	local w = s:get_parent().Workers:get(s:get_id_worker())
	w:set_active(s.cpu)
	w:add_listener('update', s)
	s:debug("Add listener: " .. tostring(s))
end)

function M:onupdate()
	self:debug("Widget update: " .. tostring(self:get_module_name())) --._module.name)
		
	if not self.parent then 
		self:warn(self:get_module_name() .. " No parent, so no data")
		return
	end
	local data = self:get_parent().Workers:get(self:get_id_worker()).data[self.cpu] 
	self:debug("Frequency : " .. data.cur_freq)
	local name = ""
	if data.cur_freq == data.freq_steps[4]  then
		name = "4.png"
	elseif data.cur_freq >= data.freq_steps[3]    then
		name = "3.png"
	elseif data.cur_freq >= data.freq_steps[2] then
		name = "2.png"
	else
		name = "1.png"
	end 	
	self.widgets.icon.image = self.parent.ImageCache:get_image(self.image_path .. name)
	return self
end

return M
