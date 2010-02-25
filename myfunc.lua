function file_exists(n)
	local f = io.open(n)
	if f then 
		io.close(f)
		return true
	end
	return false
end
