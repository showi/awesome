local cbase = require("delicious.base")

local CDATA = {
	parent = nil,
	_module = {
		name = "delicious.workers.one"
	}
}

local M = delicious_class(cbase, function(s, ...)
	s:_base_init()
	s:set_module_name("delicious.workers.one")
	s:debug("New module [" .. s:get_module_name() .. "]")
	s.parent = arg[1]
	s.id = arg[2].id
	s.wtype = arg[2].wtype
	s.refresh = arg[2].refresh
	s.args = arg[2]
	s.type = arg[2].wtype
	if s.wtype == "cpufreq" then
		s.cpu = arg[2].cpu
	elseif s.wtype == "net" then
		s.nif = arg[2].nif
	end
	s:debug("Creating worker["..s.id.."] " .. s.type .. "(" .. s.refresh .. ")") 
end)

return M
