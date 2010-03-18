local delicious = delicious
local delicious_class = delicious_class
local math = math
local tonumber = tonumber
local os = os
local io = io
local string = string
local table = table
local pairs = pairs
local print = print
local tostring = tostring
setfenv(1, {})

local M = delicious_class(delicious:get_class('delicious.workers.base'), function(s, ...)
	s:_base_init("delicious.workers.bat")
	s.parent = arg[1]
	s.batteries = {}
	s.state = "Unknown"
	s.data = {}
	s.last_time = os.time()
	s.syspath = "/sys/class/power_supply/"
	if not s:probe() then
		s:warn("Cannot found battery in your system")
	--else
		--for _, id in pairs(s.batteries) do
			--print("Battery present: " .. id)
		--end
	end
	local refresh
	if arg[2] and arg[2].refresh then refresh = arg[2].refresh else refresh = 7 end
	s:set_refresh(refresh)
end)

function M:probe()
	local h = io.popen("ls -d "..self.syspath .. "BAT*/")
	if not h then 
		self:warn("Cannot probe battery")
		return false
	end
	local FOUND = false
	local line = h:read()
	while line do
		local id = string.match(line, "^"..self.syspath.."BAT(%d+)/$")
		if not id then line = h:read(); do break end end
		id = tonumber(id)
		table.insert(self.batteries, id)
		FOUND = true
		line = h:read()
	end
	h:close()
	return FOUND
end

function M:update(elapsed)
	if #self.batteries < 1 then
		self:warn("There is no battery in your system, stopping worker")
		self:stop()
		return false
	end
	local table = delicious:get_class("delicious.util.table")
	local nltws = delicious.string.nltws
	local NEED_UPDATE = false
	for _, id in pairs(self.batteries) do	
		local path = self.syspath .. "BAT" .. id .. "/status"
		local battery = table.pathtotable(self.syspath .. "BAT" .. id .. "/")
		local newdata = {
			status = nltws(battery.status) or "Unknown",
		}
		newdata.state = newdata.status
		-- Capacity
		if battery.charge_now then
			newdata.remaining, newdata.capacity = 
				nltws(battery.charge_now), nltws(battery.charge_full)
		elseif battery.energy_now then
			newdata.remaining, newdata.capacity = 
				nltws(battery.energy_now), nltws(battery.energy_full)
		else 
			newdata.state = "Unknown"
		end
		-- Percentage
		if newdata.state ~= "Unknown" then
			newdata.percent = math.min(math.floor(newdata.remaining / newdata.capacity * 100), 100)
			-- Rate
			if battery.current_now then
				newdata.rate = nltws(battery.current_now)
			end
		end
		if newdata.rate then
			-- Timeleft
			if newdata.state == "Charging" then
				newdata.timeleft = (tonumber(newdata.capacity) - tonumber(newdata.remaining))
					/ tonumber(newdata.rate)
			elseif newdata.state == "Discharging" then
				newdata.timeleft = tonumber(newdata.remaining) / tonumber(newdata.rate)
			end
			-- Hoursleft & Minutesleft
			if newdata.timeleft then
				newdata.hoursleft = math.floor(newdata.timeleft)
				newdata.minutesleft = math.floor((newdata.timeleft - newdata.hoursleft) * 60)
			end
		end
		-- Check if data has changed
		if table.cmp(newdata, self.data[id], "update") then
			newdata.update = false
			self.data[id].update = false
		else
			newdata.update = true
			NEED_UPDATE = true
			self.data[id] = newdata
		end
	end
	-- Set global state
	if NEED_UPDATE then
		local state = "Discharging"
		for id, b in pairs(self.data) do
			if b.state == "Charging" then state = "Charging" end
		end
		self.state = state
	end
 	--print (self:tostring())
	return NEED_UPDATE
end

function M:tostring()
	local str = "Global state: " .. self.state .. "\n"
	for id, b in pairs(self.data) do
		str = str .. "[BAT".. id .. "]\n"
		.. "status.....: " .. b.status .. "\n"
		.. "state......: " .. b.state .. "\n"
		.. "percent....: " .. b.percent .. "\n"
		.. "remaining..: " .. tostring(b.remaining) .. "\n" 
		.. "capacity...: " .. tostring(b.capacity) .. "\n" 
		.. "rate.......: " .. tostring(b.rate) .. "\n" 
		.. "timeleft...: " .. tostring(b.timeleft) .. "\n" 
		.. "hoursleft..: " .. tostring(b.hoursleft) .. "\n" 
		.. "minutesleft: " .. tostring(b.minutesleft) .. "\n" 
		.. "update.....: " .. tostring(b.update) .. "\n" 
	end
	return str
end
return M
