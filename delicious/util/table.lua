local delicious_class = delicious_class
local delicious = delicious
local setmetatable = setmetatable
local io = io
local pairs = pairs 
local table = table
local print = print
local type = type
setfenv(1, {})

local M = delicious_class(delicious:get_class("delicious.base_core"), function(s, ...)
end)

function M.notkeys(t, tkeys)
	if not t then return nil end
	local dtable = {}
	for _, k in pairs(t) do
		local keep = true
		for _, nk in pairs(tkeys) do
			if nk == k then 
				keep = false
				break
			end
		end 
		if keep then 
			table.insert(dtable, k)
		end
	end
	return dtable
end

-- {{{ Helper functions (From vicious)
-- {{{ Expose path as a Lua table
function M.pathtotable(path)
    return setmetatable({},
        { __index = function(_, name)
            local f = io.open(path .. '/' .. name)
            if f then
                local s = f:read("*all")
                f:close()
                return s
            end 
        end 
    })  
end

function M.cmp(t1, t2, nocmp)
	if not t1 and not t2 then return true end
	if t1 and not t2 then return false end
	if t2 and not t1 then return false end
	for k, d in pairs(t1) do
		--print("Comp key: " .. k)
		if nocmp then if k == nocmp then do break end end end
		if type(d) ~= type(t2[k]) then return false end
		if type(d) == "table" then
			return M.cmp(d, t2[k])
		end
		if d ~= t2[k] then return false end
	end
	return true
end

return M
