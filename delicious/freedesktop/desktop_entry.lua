local tag_start = "[Desktop Entry]"

local valid_keys = {
	Version = true, Name = true, Comment = true, Exec = true, Icon = true, Terminal = true,
	Type = true, Categories = true, StartupNotify = true,
}

local path_fdapps = {
	"/usr/share/applications/",
	awful.util.getdir("config") .. "/freedesktop/applications/"
}

local M = delicious_class(delicious:get_class("delicious.base_core"), function(s, ...)
	s:_base_init("delicious.freedesktop.desktop_entry")
	s.name = arg[1]
	s.data = {}
	s:set_debug(true)
end)


function M:parse_line(line) 
	local k, v = string.match(line, "^%s*(.*)%s*=%s*(.*)%s*$")
	if k and v then
		if not self.data[k] then self.data[k] = {} end
		local mk, mv = string.match(k, "^(.*)%[(.*)%]$")
		if mk and mv then
			self.data[mk][mv] = v 
			else
			self.data[k]['default'] = v
		end
	end
end

function M:read(_name)
	if _name then self.name = _name end
	local found_tag = false
	local h = nil
	for k, path in pairs(path_fdapps) do
		local fdpath = path .. self.name .. ".desktop"
		h = io.open(fdpath)
		if h then 
			break
		end
	end
	if not h then
		self:warn("Cannot found freedesktop entry for " .. self.name)
		return false
	end
	for line in h:lines() do
		if not found_tag and string.match(line, "^%s*%[Desktop Entry%]%s*$") then
			found_tag = true
		elseif found_tag then
			self:parse_line(line)
		end
	end
	h:close()
	return found_tag
end

function M:add(key, value, lang)
	if not key then
		self:warn("Cannot add entry with empty key")
		return 
	end
	if not valid_keys[key] then
		self:warn("Invalid key: " .. key)
		return
	end
	if not self.data[key] then self.data[key] = {} end
	if lang then
		self.data[key][lang] = value
	else
		self.data[key].default = value
	end
end

function M:get(key, lang)
	if not self.data[key] then return nil end
	if lang then
		if self.data[key][lang] then 
			return self.data[key][lang]
		end 
	end
	if self.data[key].default then return self.data[key].default end
	return nil
end

function M:write(_path)
	local u = delicious:get_class("delicious.util.file")
	local file = _path .. self.name .. ".desktop"
	if u.file_exists(file) then
		self:warn("File " .. file .. " already exists")
		return false
	end
	local h = io.open(file, 'w')
	if not h then
		self:warn("Cannot open file " .. file .. " for writing")
		return false
	end
	h:write(tag_start, "\n")
	for k, t in pairs(self.data) do
		for e, v in pairs(t) do
			if e == "default" then
				h:write(k .. "=" .. v, "\n")
			else
				h:write(k .. "["..e.."]=" .. v, "\n")
			end
		end
	end	
	h:close()	 
end

function M:tostring()
	local str = tag_start .. "\n"
	for k, t in pairs(self.data) do
			for name, value in pairs(t) do
				if name == "default" then
					str = str .. k .. "= " .. value
				else 
					str = str .. k .. "[" .. name .. "]" .. "= " .. value
				end
				str = str .. "\n"
			end
	end
	return str
end

return M
