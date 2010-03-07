local cbase = require("delicious.widget.base")

local M = delicious_class(cbase, function(s, args)
	s:_base_init()
	s:set_module_name("delicious.widget.net")
	print("if: " .. tostring(args.nif))
	print("refresh: " .. tostring(args.refresh))
	s.parent.Workers:add('net', args)
end)

return M
