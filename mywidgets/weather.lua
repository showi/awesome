require("myfunc")

-- Variables
local img_dir = awful.util.getdir("config") .. "/img/weather/"

-- Weather icon (for systray)
icon_weather = widget({type = "imagebox", layout = awful.widget.layout.horizontal.rightleft})
icon_weather.image = img_weather_na

-- Enable caching
vicious.enable_caching(vicious.widgets.weather)

-- Creating widget
w_weather = widget({ type = "textbox", layout = awful.widget.layout.horizontal.rightleft})
vicious.register(w_weather, vicious.widgets.weather, 
    function(widget, args)
		local weather = args["{weather}"]
		local imgpath = img_dir .. "na.png"
        if not weather then 
            return "NoData"
        end
		if string.find(weather, "^[%a%s]+$") then
			local imgname = string.gsub(weather, " ", "_") .. ".png"
			imgpath = img_dir .. imgname
			if not file_exists(imgpath) then
				print("weather widget unknow weather: " .. imgpath)
				imgpath = img_dir .. "na.png"
			end
		else
			print("Invalid weather string")
		end
		icon_weather.image = image(imgpath)
        return string.format("%2i°C", args["{tempc}"])
end, 29, "LSGC")

-- Creating tooltip
local t_weather = awful.tooltip({
    obj = {k},
    timer_function = function()
        c = vicious.get_cache(vicious.widgets.weather) -- get_cache is not in vicious 
        if c == nil then
            return "No data in cache"
        end 
        str =  "City......: " .. c.data["{city}"] .. "\n"
            .. "Wind......: " .. c.data["{wind}"] .. "\n"
            .. "Wind.speed: " .. c.data["{windkmh}"] .. " KmH\n"
            .. "Sky.......: " .. c.data["{sky}"] .. "\n"
            .. "Weather...: " .. c.data["{weather}"] .. "\n"
            .. "Temp      : " .. c.data["{tempc}"] .. "°C\n"
            .. "Humidity..: " .. c.data["{humid}"] .. "\n"
            .. "Pressure..: " .. c.data["{press}"] .. "\n"
			.. "Last update on : " .. os.date("%c", c.time)
        return str 
    end,
})

-- register tooltip within weather widget
t_weather:add_to_object(w_weather)
t_weather:add_to_object(icon_weather)

