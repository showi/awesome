local img_dir = awful.util.getdir("config") .. "/img/"
local M = {}
M.mt = {}
M.prototype = {
	time = os.time(),
	Animation = nil,
	index = 1,
	timer = nil,
	speed = 1,
}
--[[ Method start
	
]]--
M.prototype.set_speed = function(_s, speed)
	_s.speed = speed
end
M.prototype.get_speed = function(_s, speed)
	return _s.speed 
end
M.prototype.start = function(_s)
	_s.index = 1
	local i = _s.Animation.get_image(_s.Animation, 1)
	_s.widget.image = i.get_image(i)
	_s.timer = timer({ timeout = i.duration}) --function(_s) _s.next(_s) end)
	_s.timer:add_signal("timeout", function()
		if not _s.Animation then return end 
		_s.timer.stop(_s.timer)
		--print("---\ntimeout")
		--print("flag: " .. _s.flag)
		local i = _s.Animation.get_image(_s.Animation, _s.index)
		if not i then
			_s.index = 1
			i = _s.Animation.get_image(_s.Animation, _s.index)
		end
		_s.widget.image = i.get_image(i)
		_s.index = _s.index + 1
		_s.timer.timeout = i.duration * _s.speed
		_s.timer:start()
	end)
	_s.timer:start()
end

M.prototype.stop = function(_s)
	if not _s.timer then
		return
	end
	_s.timer.stop()
	_s.timer = nil
end
-- Method next
M.prototype.next = function(_s)
	local d =  os.difftime(os.time(), _s.time)
	if d > _s.current.duration then
		local i = _s.index + 1
		if not _s.Animation.images[i] then
			if _s.index == 0 then
				print("Erreur: there's no image")
				return nil
			end
			_s.index = 0
		end
		_s.index = _s.index + 1
		local i = _s.Animation.get_image(_s.Animation, _s.index)
		_s.widget.image = i.get_image(i)
		_s.timer.timeout = i.duration * _s.speed
		_s.timer.start()
	end
end


M.new = function(_widget, _animation)
	print("New controler")
    local self = {}
    setmetatable(self, M.mt)
    --self.path = path
	self.Animation = _animation
	self.widget = _widget
	self.index = 1
	return self
end

M.mt.__index = function(table, key)
    return M.prototype[key]
end

return M

