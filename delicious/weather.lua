vicious.enable_caching(vicious.widgets.weather)

local img_dir = "weather/"

local M = {}
M.mt = {}
M.cache = {}

M.prototype = {
	station = "",
	refresh = 29,
	w_weather = nil,
	t_weather = nil,
	registered = nil,
	theme = {
		layout = awful.widget.layout.horizontal.rightleft
	}
}

local function img_from_string(args) 
	local icon = img_dir .. "na.png"
	if not args then
		return image(icon)
	end
	local string = args["{weather}"]
	if  not string or string == "N/A" then
		string = args["{sky}"]
	end
   	string = string.match(string, "^%s*([%a%s]+)%s*([,;%a%s]*)$")
	if string then
		string = trim (string)
		string = string.gsub(string, "%s", "_") .. ".png"
		icon = img_dir .. string
	end
	print("weather: " .. icon)
	return icon
end

M.prototype.register = function(_s, station, refresh)
	if _s.registered then
		vicious.unregister(vicious.weather, 0,_s.registered)
		_s.registered = nil
	end
	_s.registered = vicious.register(_s.widgets.text, vicious.widgets.weather, 
    	function(widget, args)
			_s.widgets.icon.image = M.cache.get_image(img_from_string(args))
			if string.match(args["{tempc}"], "^[%d-]+$") then
				return string.format("%2i°C", args["{tempc}"])
			else
				return "n/a"
			end
		end, refresh, station)
end

M.set_image_cache = function(cache)
	M.cache = cache
end

M.prototype.create_tooltip = function(_s) 
	local tooltip = awful.tooltip({
	    obj = {k},
	    timer_function = function()
	        local c = vicious.get_cache(vicious.widgets.weather) -- get_cache is not in vicious 
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
	tooltip:add_to_object(_s.widgets.icon)
	tooltip:add_to_object(_s.widgets.text)

end

M.prototype.get_widgets = function(_s)
	return _s.widgets
end

M.mt.__index = function(t, k)
	return M.prototype[k]
end

M.new = function(station, refresh)
	local self = {}
	setmetatable(self, M.mt)
	self.widgets = {
		icon = widget({type = "imagebox"}),
		text = widget({type = "textbox", width = 15}),
		layout = self.theme.layout
	}
	self.register(self, station, refresh)
	self.create_tooltip(self)
	return self
end

return M
