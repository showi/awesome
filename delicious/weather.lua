local setmetatable = setmetatable
local awful = awful
local widget = widget
local vicious = vicious
local string = string
local print = print
local image = image
local os = os 
local wibox = wibox 
module ("delicious.weather")

local station = ""
local refresh = 29
local img_dir = awful.util.getdir("config") .. "/img/weather/"
local w_weather = nil
local t_weather = nil
local registered = nil

-- Weather icon (for systray)
local icon_weather = widget({type = "imagebox", layout = awful.widget.layout.horizontal.rightleft})
icon_weather.image = img_weather_na

-- Enable caching
vicious.enable_caching(vicious.widgets.weather)

local function register(station, refresh)
	if registered then
		vicious.unregister(vicious.weather, 0,registered)
	end
	registered = vicious.register(w_weather, vicious.widgets.weather, 
    	function(widget, args)
    	    local weather = args["{weather}"]
    	    local imgpath = img_dir .. "na.png"
    	    if not weather then 
    	        return "NoData"
    	    end 
    	    weather = string.match(weather, "^([%a%s]+)([,;%a%s]*)$")
    	    if weather then
    	        weather = string.lower(weather) 
    	        local imgname = string.gsub(weather, " ", "_") .. ".png"
    	        imgpath = img_dir .. imgname
    	        if not file_exists(imgpath) then
    	            print("weather widget unknow weather: " .. imgpath)
    	            imgpath = img_dir .. "na.png"
    	        end 
    	    else
				print("weather: " .. args["{weather}"])
    	        print("Invalid weather string")
    	    end 
    	    icon_weather.image = image(imgpath)
    	    if string.match(args["{tempc}"], "%d+") then
				return string.format("%2i°C", args["{tempc}"])
			else
				return "N/A"
			end
		end, refresh, station)
end

local function create_tooltip() 
	t_weather = awful.tooltip({
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

end

-- Creating widget
local function create_widget (station, refresh)
	w_weather = widget({ type = "textbox", layout = awful.widget.layout.horizontal.rightleft})
	register(station, refresh)
end

function display(_station, _refresh)
	if not w_weather then
		create_widget(_station , _refresh)
		register(_station, _refresh)
		create_tooltip()
	end
	return {w_weather, icon_weather, layout = awful.widget.layout.horizontal.rightleft}
end


setmetatable(_M, { __call = function(_, ...) return display(...) end })