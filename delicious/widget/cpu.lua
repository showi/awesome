local M = delicious_class(delicious:get_class('delicious.widget.base'), function(s, ...)
	s:_base_init("delicious.widget.cpu")
	s:set_parent(delicious)
	s.events = {}
	s:set_id_worker(s.parent.Workers:add('cpu', arg[1]))
	s.widgets = { 
		graph = awful.widget.graph.new({ width = 30, height = 18, layout = awful.widget.layout.horizontal.rightleft, background_color = beautiful.bg_focus,}),
		layout = awful.widget.layout.horizontal.rightleft,
	}
	s.widgets.graph:set_max_value(100)
	s.widgets.graph:set_background_color("#111111")
	s.widgets.graph:set_border_color("#777777")
	s.widgets.graph:set_color("#FF0000")
	s.widgets.graph:set_gradient_colors({"#AECF96", "#88A175", "#FF5656"})	
	local w = s:get_parent():get_worker(s:get_id_worker())
	w:add_listener('update', s)
end)

function M:onupdate()
	if not self.parent then 
		self:warn("No parent, no data")
		return
	end
	local data = self:get_parent():get_worker(self:get_id_worker()).data 
	self.widgets.graph:add_value(data.total.usage)	
	
end

return M
