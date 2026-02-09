local Base = require("ui.base")
local Manager = require("ui.manager")
local theme = require("ui.theme")

local Scrollable = setmetatable({}, { __index = Base })
Scrollable.__index = Scrollable

function Scrollable.new(props)
	local self = setmetatable(Base.new("scrollable", props.x, props.y, props.w, props.h), Scrollable)

	self.children = props.children or {}
	self.scrollY = 0
	self.scrollSpeed = props.scrollSpeed or 20
	self.bgColor = props.bgColor or theme.getColor("background")
	self.border = props.border or false
	self.borderWidth = props.borderWidth or 2
	self.borderColor = props.borderColor or theme.getColor("primary")

	self:updateContentHeight()

	Manager.add(self)
	return self
end

function Scrollable:updateContentHeight()
	local maxH = 0
	for _, child in ipairs(self.children) do
		-- Calculate height relative to the top of the scrollable container
		maxH = math.max(maxH, (child.y - self.y) + (child.h or 0))
	end
	self.contentHeight = maxH
end

function Scrollable:addChild(child)
	table.insert(self.children, child)
	self:updateContentHeight()
end

function Scrollable:update(dt)
	for _, child in ipairs(self.children) do
		if child.update then
			child:update(dt)
		end
	end
	-- If Base.update exists and handles logic, keep it here
	if Base.update then
		Base.update(self, dt)
	end
end

function Scrollable:draw()
	local sx, sy, sw, sh = love.graphics.getScissor()
	-- Apply clipping so children don't render outside the box
	love.graphics.setScissor(self.x, self.y, self.w, self.h)

	-- Background
	love.graphics.setColor(self.bgColor)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

	love.graphics.push()
	-- Move the coordinate system up as we scroll down
	love.graphics.translate(0, -self.scrollY)

	for _, child in ipairs(self.children) do
		if child.draw then
			child:draw()
		end
	end
	love.graphics.pop()

	-- Border (drawn after pop so it isn't affected by scroll)
	if self.border then
		love.graphics.setColor(self.borderColor)
		love.graphics.setLineWidth(self.borderWidth)
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
	end

	love.graphics.setScissor(sx, sy, sw, sh)
end

function Scrollable:isMouseOver(mx, my)
	return mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h
end

function Scrollable:mousepressed(mx, my, button)
	if not self:isMouseOver(mx, my) then
		return false
	end

	for _, child in ipairs(self.children) do
		if child.mousepressed then
			-- IMPORTANT: Add scrollY to the mouse position to match
			-- the translated coordinate system used in Draw
			local clicked = child:mousepressed(mx, my + self.scrollY, button)
			if clicked then
				return true
			end
		end
	end
	return false
end

function Scrollable:mousereleased(mx, my, button)
	for _, child in ipairs(self.children) do
		if child.mousereleased then
			local released = child:mousereleased(mx, my + self.scrollY, button)
			if released then
				return true
			end
		end
	end
	return false
end

function Scrollable:wheelmoved(x, y)
	local mx, my = love.mouse.getPosition()
	if self:isMouseOver(mx, my) then
		self.scrollY = self.scrollY - y * self.scrollSpeed

		-- Clamp scrolling
		local maxScroll = math.max(0, self.contentHeight - self.h)
		self.scrollY = math.min(math.max(0, self.scrollY), maxScroll)
	end

	-- Forward to children (e.g., a scrollable inside a scrollable)
	for _, child in ipairs(self.children) do
		if child.wheelmoved then
			child:wheelmoved(x, y)
		end
	end
end

return Scrollable
