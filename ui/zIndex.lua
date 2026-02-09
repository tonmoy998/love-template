local ZIndex = {
	active = false,
	queue = {},
	order = 0,
}

-- Start collecting draw calls
function ZIndex:start()
	self.active = true
	self.queue = {}
	self.order = 0
end

-- Register an object for drawing
function ZIndex:draw(object)
	if not self.active then
		-- fallback: draw immediately
		if object.draw then
			object:draw()
		end
		return
	end

	self.order = self.order + 1

	table.insert(self.queue, {
		object = object,
		z = object.zIndex or 0,
		order = self.order,
	})
end

-- Stop & draw everything sorted
function ZIndex:stop()
	self.active = false

	table.sort(self.queue, function(a, b)
		if a.z == b.z then
			-- same zIndex → earlier added draws first
			return a.order < b.order
		end
		-- lower zIndex draws first
		return a.z < b.z
	end)

	for _, item in ipairs(self.queue) do
		if item.object.draw then
			item.object:draw()
		end
	end

	self.queue = {}
end

return ZIndex
