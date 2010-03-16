--local old_G = _G
local delicious = delicious
local delicious_class = delicious_class
--_G = {}

local M = delicious_class(delicious:get_class("delicious.base_core"), function(s, ...)
	s:_base_init("delicious.tk.widget.tag")	
	local img = delicious:get_image("delicious/animation/game/smwqblock/smwqblock-1.png")
	s.t_labels = {}
	s.label = widget({type = "textbox"})
	s.label.text = "Hello"
	s.label.width = 100
	s.sep = widget({type = "textbox"})
	s.sep.text = ":"
	s.prompt = awful.widget.prompt()
	s.wibox = awful.wibox({
				geometry = { x= 200, y = 200},
				--align = 'center',
				floating = true,
				width = 200,
				height = 200,
				ontop = true,
			})
	--s.wibox:rounded_corners(100)
	--s.wibox:geometry({x=200, y=200})
	--wibox.move(s.wibox)
	local l1 = s:get_label('nom', "gombatta")
	s.wibox.widgets = l1.delicious.widgets
end)

function M:get_label(label, value)
	local w = awful.wibox({
		geometry = { x= 200, y = 200},
		floating = true,
		width = 200,
		height = 200,
		ontop = true,
	})
--				widgets = { 
--						{	s.label , s.sep , s.prompt,
--							layout = awful.widget.layout.horizontal.leftright,
--							width = 200,
--						},
--					},
	w.delicious = { widgets = {
						{
			w_label = widget({type = "textbox", text = label, width = 100}),
			w_sep = widget({ type = "textbox", text = ":",
							width = 200,
						}),
							layout = awful.widget.layout.horizontal.leftright,
					},
	}}
	function w.get_widgets (s)
		self.wibox.widgets = {s.delicious.widgets.w_label}
		return self.wibox
	end 
	--s.wibox:rounded_corners(100)
	--s.wibox:geometry({x=200, y=200})
	--wibox.move(s.wibox)
	return w
end

function M:get_widgets()
	return self.wibox	
end

return M
