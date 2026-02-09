local Base = require("ui.base")
local Theme = require("ui.theme")
local Manager = require("ui.manager")
local Window = require("ui.components.window")

local Scroll = setmetatable({}, { __index = Base })
Scroll.__index = Scroll

function Scroll.new(props)
	props = props or {}

	local self = setmetatable(Base.new("scroll", props.x, props.y, props.w, props.h), Scroll)

	self.x = props.x or 100
	self.y = props.y or 100
	self.w = props.w or 500
	self.h = props.h or 600

	self.type = props.type or "vertical"
	self.variant = props.variant or "primary"

	self.scrollY = props.scrollY or 0
	self.scrollX = props.scrollX or 0
	self.scrollSpeed = props.scrollSpeed or 30

	self.border = props.border ~= nil and props.border or true
	self.lineWidth = props.lineWidth or 2
	self.borderAlpha = props.borderAlpha or 1
	self.borderColor = props.variant or "primary"

	self.window = Window.new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		border = self.border,
		lineWidth = self.lineWidth,
	})

	self.visible = true
	Manager.add(self)
	return self
end

function Scroll:draw()
	-- Manager handles drawing; nothing here by design
	if not self.visible then
		return
	end
end

function Scroll:update(dt)
	for _, child in pairs(self.window.children) do
		if child.y <= self.y + 4 then
			child.visible = false
		elseif child.y >= self.h + self.y - 4 then
			child.visible = false
		else
			child.visible = true
		end
	end

	Base.update(self, dt)
end

function Scroll:wheelmoved(x, y)
	for _, child in ipairs(self.window.children) do
		child.y = child.y + (y * self.scrollSpeed)
	end
end

return Scroll
