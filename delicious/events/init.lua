local M = delicious_class(delicious:get_class("delicious.base"), function(self, ...)
	self:_base_init("delicious.events")
	self:debug("NEW")
	self.queue = delicious:get_class("delicious.util.llist")()
	self.max = 100
	self.count_event = 0
	--local e = delicious:get_class("")
end)

function M:add(event)
	if not event then
		self:warn("Cannot add nil event")
		return false
	end
	if self.count_event >= self.max then
		self:warn("Cannot add event maximul limit reach")
		return false
	end
	local n = self.queue:insert(event)
	self:debug("Adding event")
	self.count_event = self.count_event + 1
	return true
end
return M
