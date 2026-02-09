-- ui/components/window.lua
local Base = require("ui.base")
local Manager = require("ui.manager")
local theme = require("ui.theme")

local Window = setmetatable({}, { __index = Base })
Window.__index = Window

function Window.new(props)
	props = props or {}

	local self = setmetatable(Base.new("window", props.x or 0, props.y or 0, props.w or 200, props.h or 150), Window)

	self.bg = props.bg or theme.getColor("background")
	self.border = props.border or false
	self.borderColor = props.borderColor or theme.getColor("primary")
	self.lineWidth = props.borderWidth or 2
	self.radius = props.radius or 0
	self.padding = props.padding or 10

	self.children = {}
	self.blocksInput = true -- 🔒 IMPORTANT
	self.enabled = props.enabled ~= false
	self.visible = props.visible ~= false
	self.variant = props.variant or "primary"

	self.onClick = props.onClick -- optional

	Manager.add(self)
	return self
end

-- Add child using LOCAL coordinates
function Window:add(child)
	if not child then
		return
	end

	child.lx = child.lx or child.x or 0
	child.ly = child.ly or child.y or 0
	child.visible = true

	-- Initial positioning
	child.x = self.x + self.padding + child.lx
	child.y = self.y + self.padding + child.ly

	table.insert(self.children, child)

	-- Remove from manager so it is owned by window
	if Manager.remove then
		Manager.remove(child)
	end

	return child
end

-- Update
function Window:update(dt)
	if not self.visible or not self.enabled then
		return
	end

	self.bg = theme.getColor(self.variant)
	self.borderColor = theme.getColor("primary")

	for _, child in ipairs(self.children) do
		if child.visible then
			child.x = self.x + self.padding + child.lx
			child.y = self.y + self.padding + child.ly

			if child.update then
				child:update(dt)
			end
		end
	end
end

-- 🔒 INPUT HANDLING (CRITICAL)
function Window:mousepressed(mx, my, button)
	if not self.visible or not self.enabled then
		return false
	end

	-- If click is outside window → do nothing
	if not self:isMouseOver(mx, my) then
		return false
	end

	-- Check children FIRST (top-down order)
	for i = #self.children, 1, -1 do
		local child = self.children[i]
		if child.visible and child.mousepressed then
			if child:mousepressed(mx, my, button) then
				return true
			end
		end
	end

	-- Consume click even if empty space
	self.pressed = true
	return true
end

function Window:mousereleased(mx, my, button)
	if not self.visible or not self.enabled then
		return false
	end

	-- Release children first
	for i = #self.children, 1, -1 do
		local child = self.children[i]
		if child.visible and child.mousereleased then
			if child:mousereleased(mx, my, button) then
				return true
			end
		end
	end

	if self.pressed then
		self.pressed = false
		if self.onClick and self:isMouseOver(mx, my) then
			self.onClick(self)
		end
		return true -- 🔒 BLOCK LOWER INPUT
	end

	return false
end

-- Draw
function Window:draw()
	if not self.visible then
		return
	end

	local r, g, b, a = love.graphics.getColor()

	-- Background
	love.graphics.setColor(self.bg)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.radius, self.radius)

	-- Border
	if self.border then
		love.graphics.setColor(self.borderColor)
		love.graphics.setLineWidth(self.lineWidth)
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.radius, self.radius)
	end

	-- Children
	for _, child in ipairs(self.children) do
		if child.visible and child.draw then
			child:draw()
		end
	end

	love.graphics.setColor(r, g, b, a)
end

function Window:delete()
	for i, child in ipairs(self.children) do
		Manager.remove(child)
		Manager.remove(self)
	end
end

return Window
