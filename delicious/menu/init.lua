local M = delicious_class(delicious:get_class("delicious.base_core"), function(s, ...)	
	s:_base_init("delicious.menu")
	s:set_parent(arg[1])
	s.data = {}	
	s.prop = {
		lang = nil,
		category = {
			depth = nil,
			filter = nil,
		}
	}
	if arg[2].lang then s.prop.lang = arg[2].lang end
	if arg[2].depth then s.prop.category.depth   = arg[2].depth end
	if arg[2].filter then s.prop.category.filter = arg[2].filter end
	local list = arg[2].list
	if not arg[2].list then 
		s:warn("Cannot build menu without argument list")
	else
		s:build(arg[2].list)
	end
end)

local icon_default_app    = awful.util.getdir("config") .. "/img/delicious/pixmaps/default-app.png"
local icon_default_folder = awful.util.getdir("config") .. "/img/delicious/pixmaps/default-folder.png"

function M:probe_icon(name)
    local u = delicious:get_class("delicious.util.file")
    local ipath = { 
        "/usr/share/pixmaps/",
        "/usr/share/app-install/icons/",
        "/usr/share/icons/hicolor/16x16/apps/",
    }   
    local formats = { "png", "xpm"}
    for i, path in pairs(ipath) do
        local file = path .. name
        if u.isfile(file) then
            return file
        end 
        for iformat, format in pairs(formats) do
            local file = path .. name .. "." .. format
            if u.isfile(file) then
                return file
            end 
        end 
    end 
    return nil 
end

function M:build(list)
	local de = delicious:get_class("delicious.freedesktop.desktop_entry")
	local utable = delicious:get_class("delicious.util.table")
	local u = delicious:get_class("delicious.util.file")
	for i, item in pairs(list) do
		if not u.isinpath(item)	then
			self:warn("You are trying to add executable which is not in path '"..item.."'")
		else
			local e = de(item)
			if not e:read() then
				e:add("Name", item)
				e:add("Terminal", "false")
				e:add("Type", "Application")
				e:add("Exec", item)
				e:add("StartupNotify", "false")
				e:add("Icon", "")	
				e:write(awful.util.getdir("config") .. "/freedesktop/applications/")	
			end
			local categories = e:get("Categories")
			if categories then categories = categories:split(";") end
			if self.prop.category.filter then
				categories = utable.notkeys(categories, self.prop.category.filter)	
			end
			if not categories then categories = { "Other" } end
			local root = self.data
			local catcount = 1
			local catmax = self.prop.category.depth
			for i, c in pairs(categories) do
				if c and c ~= "" then
					if catmax then if catcount > catmax then break end end	
					if not root[c] then root[c] = {} end
					root = root[c]
					catcount = catcount + 1
				end
			end
			table.insert(root, e)
		end
	end
end

function M:get(root)
	if not root then root = self.data end
	local menu = {}
	if root._module then 
		local u = delicious:get_class("delicious.util.file")
		local file = root:get("Icon") or root:get("Name")
		local icon =  self:probe_icon(file)
		local lang = self.prop.lang
		if icon then
			return  root:get("Name", lang),root:get("Exec"), icon
		else
			return  root:get("Name", lang),root:get("Exec")
		end
	end
	for c, t in pairs(root) do
		if t and type(t) == "table" then
			if type(c) == "string" and c ~= "" then
				table.insert(menu, {c, self:get(t)})
			else
				table.insert(menu, {self:get(t)})
			end
		end
	end
	return menu	
end

function M:tostring(root)
	if not root then root = self.data end
	local str = ""
	if root._module and root:get_module_name() == "delicious.freedesktop.desktop_entry" then 
		return root:tostring() .. "\n"
	end
	for c, t in pairs(root) do
		local ktype = type(c)
		if type(c) == "string" and c ~= "" then
			str = str .. "Category: " .. c .. "\n" 
		end
		if type(t) == "table" then
			str = str .. self:tostring(t)
		end
	end
	return str	
end

return M
