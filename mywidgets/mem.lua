-- Memory widget
w_mem= awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft})
w_mem:set_width(8)
w_mem:set_height(18)
w_mem:set_vertical(true)
w_mem:set_background_color("#494B4F")
w_mem:set_border_color("#000000")
w_mem:set_color("#AECF96")
w_mem:set_gradient_colors({ "#AECF96", "#88A175", "#FF5656"})
vicious.register(w_mem, vicious.widgets.mem, "$1", 17)

