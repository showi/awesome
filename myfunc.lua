function file_exists(n)
	local f = io.open(n)
	if f then 
		io.close(f)
		return true
	end
	return false
end

function p_keyvalue(k, v, size) 
	local lk = widget({ type = "textbox" })
	local lv = widget({ type = "textbox" })
	lk.text = k
	lk.width = size
	lv.text = v
	local wb = awful.wibox({ lk, lv })
	return wb
end
