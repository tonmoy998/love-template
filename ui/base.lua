-- ============================================================================
-- ui/base.lua
-- Base class for all UI elements
-- ============================================================================
local Base = {}
Base.__index = Base

function Base.new(type, x, y, w, h)
	local self = setmetatable({}, Base)
	self.type = type or "base"
	self.x = x or 0
	self.y = y or 0
	self.w = w or 100
	self.h = h or 30
	self.visible = true
	self.enabled = true
	self.id = tostring(self):sub(8) -- unique ID
	self.children = {}
	self.parent = nil
	self.hovered = false
	self.zIndex = 1
	return self
end

function Base:draw()
	if not self.visible then
		return
	end
	-- Override in child classes
	for _, child in ipairs(self.children) do
		child:draw()
	end
end

function Base:update(dt)
	if not self.visible then
		return
	end
	-- Override in child classes
	for _, child in ipairs(self.children) do
		child:update(dt)
	end
end

function Base:mousepressed(mx, my, button)
	if not self.enabled or not self.visible then
		return false
	end

	-- Check children first (top to bottom)
	for i = #self.children, 1, -1 do
		if self.children[i]:mousepressed(mx, my, button) then
			return true
		end
	end

	return false
end

function Base:mousereleased(mx, my, button)
	if not self.enabled or not self.visible then
		return false
	end

	for i = #self.children, 1, -1 do
		if self.children[i]:mousereleased(mx, my, button) then
			return true
		end
	end

	return false
end

function Base:keypressed(key)
	if not self.enabled or not self.visible then
		return false
	end

	for _, child in ipairs(self.children) do
		if child:keypressed(key) then
			return true
		end
	end

	return false
end

function Base:textinput(t)
	if not self.enabled or not self.visible then
		return false
	end

	for _, child in ipairs(self.children) do
		if child:textinput(t) then
			return true
		end
	end

	return false
end

function Base:isMouseOver(mx, my)
	return mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h
end

function Base:addChild(child)
	table.insert(self.children, child)
	child.parent = self
	return self
end

function Base:removeChild(child)
	for i, c in ipairs(self.children) do
		if c == child then
			table.remove(self.children, i)
			c.parent = nil
			break
		end
	end
	return self
end

function Base:setPosition(x, y)
	self.x = x
	self.y = y
	return self
end

function Base:setSize(w, h)
	self.w = w
	self.h = h
	return self
end

function Base:setVisible(visible)
	self.visible = visible
	return self
end

function Base:setEnabled(enabled)
	self.enabled = enabled
	return self
end

function Base:destroy()
	if self.parent then
		self.parent:removeChild(self)
	end

	for i = #self.children, 1, -1 do
		self.children[i]:destroy()
	end

	self.children = {}
end

return Base
