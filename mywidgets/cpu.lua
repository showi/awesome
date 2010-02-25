w_cpu = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft})
w_cpu:set_width(50)
w_cpu:set_height(18)
w_cpu:set_border_color("#000000")
w_cpu:set_background_color("#494B4F")
w_cpu:set_color("#FF5656")
w_cpu:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(w_cpu, vicious.widgets.cpu, "$1", 5)

