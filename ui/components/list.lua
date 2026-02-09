-- ui/list.lua
local Base = require("ui.base")
local Manager = require("ui.manager")
local theme = require("ui.theme")

local List = setmetatable({}, { __index = Base })
List.__index = List

function List.new(props)
	props = props or {}

	local self = setmetatable(Base.new("list", props.x or 0, props.y or 0, props.w or 200, props.h or 0), List)

	-- Data
	self.items = props.list or {}

	-- Style
	self.padding = props.padding or 12
	self.itemHeight = props.itemHeight or 36
	self.border = props.border ~= false
	self.borderWidth = props.borderWidth or 1

	self.bgColor = props.bgColor or theme.getColor("surface")
	self.borderColor = props.borderColor or theme.getColor("border")
	self.hoverColor = props.hoverColor or theme.getColor("primary")
	self.textColor = props.textColor or theme.getColor("text")
	self.font = props.font or love.graphics.getFont()

	self.hoveredIndex = nil

	self:autoSize()

	Manager.add(self)
	return self
end

-- =========================
-- Helpers
-- =========================

function List:autoSize()
	self.h = #self.items * self.itemHeight
end

local function getItemText(item)
	if type(item) == "table" then
		return item.text or ""
	end
	return tostring(item)
end

-- =========================
-- Update
-- =========================

function List:update(dt)
	Base.update(self, dt)

	self.bgColor = theme.getColor("surface")
	self.textColor = theme.getColor("text")

	local mx, my = love.mouse.getPosition()
	self.hoveredIndex = nil

	if mx < self.x or mx > self.x + self.w then
		return
	end
	if my < self.y or my > self.y + self.h then
		return
	end

	local index = math.floor((my - self.y) / self.itemHeight) + 1
	if self.items[index] then
		self.hoveredIndex = index
	end
end

-- =========================
-- Draw
-- =========================

function List:draw()
	if not self.visible then
		return
	end

	local r, g, b, a = love.graphics.getColor()

	-- Background
	love.graphics.setColor(self.bgColor)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

	-- Border
	if self.border then
		love.graphics.setColor(self.borderColor)
		love.graphics.setLineWidth(self.borderWidth)
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
	end

	-- Items
	love.graphics.setFont(self.font)

	for i, item in ipairs(self.items) do
		local itemY = self.y + (i - 1) * self.itemHeight

		-- Hover
		if self.hoveredIndex == i then
			love.graphics.setColor(self.hoverColor)
			love.graphics.rectangle("fill", self.x, itemY, self.w, self.itemHeight)
		end

		-- Text
		love.graphics.setColor(self.textColor)
		love.graphics.printf(
			getItemText(item),
			self.x + self.padding,
			itemY + (self.itemHeight - self.font:getHeight()) / 2,
			self.w - self.padding * 2,
			"left"
		)
	end

	love.graphics.setColor(r, g, b, a)
end

-- =========================
-- Mouse
-- =========================

function List:mousepressed(mx, my, button)
	if button ~= 1 or not self.hoveredIndex then
		return false
	end

	local item = self.items[self.hoveredIndex]

	if type(item) == "table" and item.onClick then
		item.onClick(item, self.hoveredIndex)
	end

	return true
end

-- =========================
-- Item API
-- =========================

function List:addItem(item)
	table.insert(self.items, item)
	self:autoSize()
end

function List:removeItem(index)
	table.remove(self.items, index)
	self:autoSize()
end

return List
