vicious.enable_caching(vicious.widgets.cpufreq)
local M = {}
M.mt = {}
M._module_name = "delicious.cpufreq"
M.prototype = {
	cpu = nil,
	refresh = nil,	
	registered = nil,
	w_cpufreq = nil,
	theme = {
		layout = awful.widget.layout.horizontal.rightleft,	
	},
	state = 0,
	widgets =  {},
	tooltip = nil
}
M.cache = nil 
local img_dir =  awful.util.getdir("config") .. "/img/cpufreq/"
-- module("delicious.cpufreq")

---
M.get_image = function(_s, path)
	return M.cache.get_image("cpufreq/" .. path)	
	--local rpath = img_dir .. path
--	if not M.cache.images[rpath] then
--		M.cache.images[rpath] = widget({type = "imagebox"})
--		M.cache.images[rpath].image = image(rpath)
--	end
--	return M.cache.images[rpath]
end

M.prototype.create_widget = function (_s)
	if _s.widgets.cpufreq then
		return nil
	end
	_s.w_cpufreq = widget({ type = "textbox", layout = _s.theme.layout })
	_s.w_cpufreq.background_color = "#494B4F"
	return _s
end

M.prototype.get_steps = function(_s)
	local ret = {}
	for i = 1,4 do ret[i] = _s.min + _s.step * i	
		print("| step: " .. ret[i])
	end	
	return ret
end
M.prototype.change_state = function(_s, state)
	_s.state = state
end
---
M.prototype.register = function(_s, cpu, refresh)
	if _s.registered then
		vicious.unregister(vicious.cpufreq, 0, _s.registered)
	end
	_s.registered = vicious.register(_s.widgets, vicious.widgets.cpufreq,
    	function(widget, args)
			local str
			if args[1] == _s.fstep[4]  then
				str = "[max]"
				_s.widgets.icon.image = M.get_image(_s, "4.png")
			elseif args[1] >= _s.fstep[3]	then
				str = "[mi-]"
				_s.widgets.icon.image = M.get_image(_s, "3.png")
			elseif args[1] >= _s.fstep[2] then
				_s.widgets.icon.image = M.get_image(_s, "2.png")
				str = "[mi+]"
			else
				_s.widgets.icon.image = M.get_image(_s, "1.png")
				str = "[min]"
			end
    	    return ""
			--return " " .. string.format("%5i MhZ", args[1])
	end, _s.refresh, _s.cpu)
end

---
M.prototype.create_tooltip = function (_s)
	local tooltip = awful.tooltip({
		obj = {k},
		timer_function = function()
			local c = vicious.get_cache(vicious.widgets.cpufreq) -- get_cache is not in vicious 
       		if c == nil then	
				return "No data in cache"
			end
			local str = "frequency: " .. c.data[1] .. " MhZ\n\n"
			         .. "voltage..:   " .. c.data[4] .. " mv\n"
			         .. "governor.:   " .. c.data[5] .. "\n"
			return str
		end,
	}) -- closure end
	for w, k in pairs(_s.widgets) do
		print("w, k: " .. w .. ",")
		if w == 'icon' then
			tooltip:add_to_object(_s.widgets[w])
		end
	end
end

M.prototype.get_widgets = function(_s)
	_s.widgets.layout = _s.theme.layout
	return _s.widgets
end
---
local function minmax(_l)
	local min, max = nil, nil
	for k, v in pairs(_l) do
		if min == nil then
			min = v
		elseif min > v then
			min = v
		end
		if max == nil then
			max = v
		elseif max < v then
			max = v
		end	
	end
	return min, max
end

M.set_image_cache = function(cache)
	M.cache = cache
end

M.prototype.init = function(_s, cpu, freq_list, refresh)
	_s.freqs = freq_list
	if not vicious or not vicious.widgets.cpufreq then
    	print("You need vicious library and vicious.cpufreq enable in vicious/init.lua")
    	return
    end
	_s.widgets.icon = widget({type = "imagebox"})
	_s.widgets.icon.image = M.get_image(self, "na.png")
	local min, max = minmax(freq_list)
	--print("min, max= " .. min .. ", " .. max)
	local step = math.floor((max - min) / 4)
	_s.step = step
	_s.min = min
	_s.max = max
	_s.fstep = {} 
	_s.fstep[1] = min
	_s.fstep[4] = max
	for i= 2,3 do
		_s.fstep[i] = min + ((i-1) * step)	
	end
	--for i= 1,4 do
	--	print("fstep: " .. _s.fstep[i])
	--end
	--print("step: " .. step)	
	--_s.create_widget(_s)
	_s.register(_s, cpu, refresh)
	_s.create_tooltip(_s)
end


M.mt.__index = function(table, key)
	return M.prototype[key]
end

M.new = function(cpu, freq_list, refresh)
	local self = {}
	setmetatable(self, M.mt)
	self.cpu = cpu
	self.refresh = refresh
	self.init(self, cpu, freq_list, refresh)
	return self
end

return M
