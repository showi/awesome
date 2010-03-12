local M = delicious_class(function(s, ...)
	s.list = arg[1]
end)

function M:start()
	self.cnode = nil
end

function M:next()
	if not self.cnode then
		self.cnode = self.list.head
		return self.cnode
	else
		if self.cnode and self.cnode.next then
			self.cnode = self.cnode.next
			return self.cnode
		end
	end
	return nil
end

function M:remove()
	if not self.cnode then
		self:warn("Cannot remove empty node")
		return nil
	end
	local tnode = self.cnode
	if not tnode.prev and not tnode.next then -- last element
		print('removing last element')
		self.list.head = nil
		self.list.tail = nil
		self.cnode = nil
		return tnode
	end
	if tnode.prev and tnode.next then
		print('removing middle element')
		local nn = tnode.next
		local pn = tnode.prev
		pn.next = nn
		nn.prev = pn
		self.cnode = pn
	elseif not tnode.prev then -- removing head
		print('removing head')
		self.list.head = tnode.next
		self.list.head.prev = nil
		self.cnode = nil
	else -- removing tail
		print('removing tail')
		self.list.tail = tnode.prev
		self.list.tail.next = nil
		self.cnode = self.list.tail
	end	
	return tnode
end

return M
