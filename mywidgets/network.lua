require("myfunc")
-- helper
function nicetx(args, ifa, tx)
	local k = ifa .. " " .. tx .. "_b"
	local kilo = 1024
	local mega = kilo * 1024
	local giga = mega * 1024
	local v = tonumber(args["{"..k.."}"])
	if v >= giga then	
		return string.format("%.1fGb", v / giga)
	elseif v >= mega then
		return string.format("%.1fMb", v / mega)
	elseif v >= kilo then
		return string.format("%.1fKb", v / kilo)
	else
		return string.format("%.1fb", v)
	end
end

-- Variables
local img_dir = awful.util.getdir("config") .. "/img/"
local w_layout = awful.widget.layout.horizontal.rightleft
local ifa = "eth0"
local update = 3 

-- Icons
icon_network_up = widget({type = "imagebox", layout = w_layout })
icon_network_up.image = image(img_dir .. "up.png")

icon_network_down= widget({type = "imagebox", layout = w_layout})
icon_network_down.image = image(img_dir .. "down.png")

-- Enable caching
vicious.enable_caching(vicious.widgets.net)

-- Net widget up
w_network_up = widget({ type = "textbox", layout = w_layout})
w_network_up.background_color = "#494B4F"
w_network_up.width = 45
vicious.register(w_network_up, vicious.widgets.net,
    function(widget, args)
        return nicetx(args, ifa, "up")
end, update)

-- Net widget down
w_network_down = widget({ type = "textbox", layout = w_layout})
w_network_down.background_color = "#494B4F"
w_network_down.width = 45
vicious.register(w_network_down, vicious.widgets.net,
    function(widget, args)
        return nicetx(args, ifa, "down")
end, update)

local t_network= awful.tooltip({
	obj = {k},
	timer_function = function()
		c = vicious.get_cache(vicious.widgets.net) -- get_cache is not in vicious 
		if c == nil then
			return "No data in cache"
		end
		str = "rx: " .. nicetx(c.data, ifa, "rx") .. "\n"
		..    "tx: " .. nicetx(c.data, ifa, "tx")
		return str
	end,
})

t_network:add_to_object(w_network_up)
t_network:add_to_object(w_network_down)
t_network:add_to_object(icon_network_up)
t_network:add_to_object(icon_network_down)
