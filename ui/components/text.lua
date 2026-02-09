local Base = require("ui.base")
local Theme = require("ui.theme")
local Manager = require("ui.manager")

local Text = setmetatable({}, { __index = Base })
Text.__index = Text

function Text.new(props)
	props = props or {}

	local self = setmetatable(Base.new("text"), Text)

	self.x = props.x or 0
	self.y = props.y or 0

	-- maxWidth is the wrapping constraint
	self.maxWidth = props.w or 300

	-- computed size (DO NOT use as wrap input)
	self.w = 0
	self.h = 0

	self.padding = props.padding or 0
	self.radius = props.radius or 0

	self.text = props.text or "Text"
	self.font = props.font or love.graphics.getFont()
	self.defaultFont = love.graphics.getFont()

	self.bg = props.bg -- nil = no background
	self.alpha = props.alpha or 1

	-- color can be theme key OR rgba table
	self.color = props.color or "text"

	self.align = props.align or "left"

	Manager.add(self)
	return self
end

-- ================= DRAW =================

function Text:draw()
	if not self.visible then
		return
	end

	love.graphics.setFont(self.font)

	-- Resolve text color
	local textColor = type(self.color) == "string" and Theme.getColor(self.color) or self.color

	-- Background
	if self.bg then
		local bg = type(self.bg) == "string" and Theme.getColor(self.bg) or self.bg

		love.graphics.setColor(bg[1], bg[2], bg[3], self.alpha)
		love.graphics.rectangle(
			"fill",
			self.x,
			self.y,
			self.w + self.padding * 2,
			self.h + self.padding * 2,
			self.radius,
			self.radius
		)
	end

	-- Text
	love.graphics.setColor(textColor[1], textColor[2], textColor[3], self.alpha)
	love.graphics.printf(self.text, self.x + self.padding, self.y + self.padding, self.maxWidth, self.align)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(self.defaultFont)
end

-- ================= UPDATE =================

function Text:update(dt)
	self:updateLayout()

	self.x = self.x
	self.y = self.y
	if self.align == "center" then
		local sw = love.graphics.getWidth()
		self.x = (sw - (self.w + self.padding * 2)) / 2
	end
end

-- ================= LAYOUT =================

function Text:updateLayout()
	local font = self.font

	local usedWidth, lines = font:getWrap(self.text, self.maxWidth)
	local lineCount = type(lines) == "table" and #lines or lines

	self.w = usedWidth
	self.h = lineCount * font:getHeight()
end

-- ================= HELPERS =================

function Text:setText(text)
	self.text = text or ""
	self:updateLayout()
end

function Text:getText()
	return self.text
end

function Text:getWidth()
	return self.w
end

function Text:getHeight()
	return self.h
end

function Text:getSize()
	return self.w, self.h
end

return Text
