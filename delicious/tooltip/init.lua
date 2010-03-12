local M = delicious_class(delicious:get_class("delicious.base"), function(s, ...)
	s:_base_init("delicious.tooltip")
	s.wibox = wibox({
		visible = true,
		screen = 1,
		width = 640, height = 480, x = 300, y = 300,
		ontop = true,
	})
end)

function M:set_widgets(w)
	self.wibox.widgets = w
end

function M:get_widgets()
	return self.wibox
end

return M
