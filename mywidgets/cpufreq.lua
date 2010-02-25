w_cpufreq = widget({ type = "textbox", layout = awful.widget.layout.horizontal.rightleft})
w_cpufreq.background_color = "#494B4F"
vicious.register(w_cpufreq, vicious.widgets.cpufreq,
    function(widget, args)
        return string.format("%5i MhZ", args[1])
end, 7, "cpu0")

