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

local M = delicious_class(delicious:get_class('delicious.widget.base'), function(s, ...)
	s:_base_init("delicious.widget.cpufreq")
	s:set_parent(delicious)
	s.id_worker = nil
	s.image_path = "delicious/widget/cpufreq/"
	s.events = {}
	s.id    = arg[1].id
	s.wtype = arg[1].id
    s.cpu   = arg[1].cpu
	s.freqs = arg[1].freqs
	s.refresh = arg[1].refresh
	s.args = arg
	s:debug("cpu: " .. arg[1].cpu)
	s:debug("freq: " .. tostring(arg[1].freqs))
	s:debug("refresh: " .. tostring(arg[1].refresh))
	s:debug("Image cache: " .. tostring(s.parent:get_image_cache()))
	local min, max = minmax(arg[1].freqs)
    local step = math.floor((max - min) / 4)
    s.step = step
    s.min = min
    s.max = max
    s.fstep = {}
    s.fstep[1] = min
    s.fstep[4] = max
	for i= 2,3 do
        s.fstep[i] = min + ((i-1) * step)
    end
	s:set_id_worker(s.parent.Workers:add('cpufreq', arg[1]))
	s:debug("Id worker: " .. s:get_id_worker())
	local w = s:get_parent().Workers:get(s:get_id_worker())

	s.widgets = { 
		icon = widget({type = "imagebox"}),
		layout = awful.widget.layout.horizontal.rightleft
	}
	s.widgets.icon.bg = beautiful.bg_focus
	s.widgets.icon.image = s.parent.ImageCache:get_image(s.image_path .. "na.png")
	w:add_listener('update', s)
	s:debug("Add listener: " .. tostring(s))
end)

function M:onupdate()
	self:debug("Widget update: " .. tostring(self)) --._module.name)
	if not self.parent then 
		self:warn(self:get_module_name() .. " No parent, so no data")
		return
	end
	local freq = self:get_parent().Workers:get(self:get_id_worker()).args[1] 
	self:debug("Frequency : " ..freq)
	local name = ""
	if freq == self.fstep[4]  then
		name = "4.png"
	elseif freq >= self.fstep[3]    then
		name = "3.png"
	elseif freq >= self.fstep[2] then
		name = "2.png"
	else
		name = "1.png"
	end 	
	self.widgets.icon.image = self.parent.ImageCache:get_image(self.image_path .. name)
	return self
end

return M
