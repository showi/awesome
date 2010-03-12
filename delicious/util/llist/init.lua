local _module_name = "delicious.util.llist"
local M = delicious_class(delicious:get_class("delicious.base_core"), function(s, ...)
	s:_base_init(_module_name)
	s.head = nil
	s.tail = nil
end)

function M:insert(data)	
	if not data then
		self:warn("Cannot add nil data")
		return nil
	end
	local node = {
		data = data,
		next = nil,
		prev = nil,
	}
	if not self.head then
		self.head = node
		self.tail = node
	else
		local tmp = self.head
		while tmp.next do 
			tmp = tmp.next
		end
		node.prev = tmp
		tmp.next = node
		self.tail = node
	end
end

function M:pop()
	local n = self.head
	if not n then
		return nil
	end
	if not n.next then
		self.head = nil
		self.tail = nil
		return n
	end
	self.head = n.next
	self.head.prev = nil
	return n
end

function M:get_iterator()
	return delicious:get_class("delicious.util.llist.iterator")(self)
end

return M
