local M = delicious_class(function(s, ...)
	print("testing dbus")
	dbus.request_name("session", "delicious.awesome.workers")
	s.signal = dbus.add_signal("delicious.awesome.workers", function()
		print('Receive signal')
	end)
end)

function M:widgets()
	local w = wibox({
--		position = "top",
		screen = 1,
		width = 200, height = 200, x = 500, y = 250,
		widgets ={
			--txt = widget({type = "textbox",
			--	background_color = "#0000FF",
			--}),
			--but_cancel = awful.widget.button({ image = delicious:get_image("delicious/invalid_image.png") }),
			background_color = "#0000FF",
		},
			layout = awful.widget.layout.horizontal.leftright,
	})
	for i = 1, 10 do
		print("insert button " .. i)
		w.widgets["but" .. tostring(i)] =
			awful.widget.button({ image = delicious:get_image("delicious/invalid_image.png"), 
				width = 20, height = 20,  x = (20 * i), y = 0}) --, layout = awful.widget.layout.horizontal.rightleft })
	end
	w.screen = 1
	--w.layout = awful.widget.layout.horizontal.rightleft
	--w:align("center")
	--w.widgets.txt.text = '<span color="red">HELLO</span>'
	return w
end

return M
