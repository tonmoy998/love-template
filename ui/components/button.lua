local Base = require("ui.base")
local Manager = require("ui.manager")
local theme = require("ui.theme")

local Button = setmetatable({}, { __index = Base })
Button.__index = Button

function Button.new(props)
	local self = setmetatable(Base.new("button", props.x, props.y, props.w, props.h), Button)

	self.text = props.text or "" -- empty text allowed
	self.icon = props.icon or props.src or nil
	self.iconGap = props.iconGap or 5
	self.iconAlign = props.iconAlign or "left" -- "left", "right", "center"
	self.iconSize = props.iconSize or 30 -- numeric value in pixels
	self.onClick = props.onClick or function() end
	self.hovered = props.hovered or false
	self.pressed = props.pressed or false
	self.variant = props.variant or "primary"
	self.font = props.font or love.graphics.getFont()
	self.radius = props.radius or 4
	self.border = props.border or false
	self.enabled = true
	self.borderWidth = props.borderWidth or 0
	self.color = props.color or theme.getColor("text")
	self.borderAlpha = props.borderAlpha or 0.2
	Manager.add(self)
	return self
end

function Button:draw()
	if not self.visible then
		return
	end
	-- Get base color for variant
	local color = theme.getColor(self.variant)

	-- Apply state modifications
	if not self.enabled then
		love.graphics.setColor(unpack(theme.getColor("disabled")))
	elseif self.pressed then
		love.graphics.setColor(color[1] * 0.7, color[2] * 0.7, color[3] * 0.7, color[4])
	elseif self.hovered then
		love.graphics.setColor(color[1] * 0.85, color[2] * 0.85, color[3] * 0.85, color[4])
	else
		love.graphics.setColor(color)
	end

	-- Draw button background
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.radius, self.radius)
	if self.border then
		love.graphics.setLineWidth(4 + self.borderWidth)
		love.graphics.setColor(color[1], color[2], color[3], self.borderAlpha)
		love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.radius, self.radius)
		love.graphics.setColor(1, 1, 1)
	end

	love.graphics.setColor(1, 1, 1)
	-- Draw icon & text
	love.graphics.setFont(self.font)
	love.graphics.setColor(unpack(theme.getColor("textInverse")))

	local textW = self.font:getWidth(self.text)
	local textH = self.font:getHeight()
	local iconW, iconH, scale = 0, 0, 1

	if self.icon then
		iconW = self.icon:getWidth()
		iconH = self.icon:getHeight()
		-- calculate scaling factor to fit desired iconSize height
		scale = self.iconSize / iconH
		iconW = iconW * scale
		iconH = iconH * scale
	end

	local spacing = (self.text ~= "" and self.icon and self.iconGap) or 0
	local totalW = textW + iconW + spacing

	local startX, textX, iconX
	startX = self.x + (self.w - totalW) / 2
	textX = startX + (self.icon and iconW + spacing or 0)
	iconX = startX

	if self.icon and self.iconAlign == "right" then
		iconX = self.x + (self.w - iconW) / 2 + (self.text ~= "" and textW / 2 + spacing / 2 or 0)
		textX = self.x + (self.w - totalW) / 2
	elseif self.icon and self.iconAlign == "center" and self.text == "" then
		iconX = self.x + (self.w - iconW) / 2
		textX = iconX
	end

	-- Draw icon
	if self.icon then
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.icon, iconX, self.y + (self.h - iconH) / 2, 0, scale, scale)
	end

	-- Draw text
	if self.text ~= "" then
		love.graphics.setColor(self.color)
		love.graphics.print(self.text, textX, self.y + (self.h - textH) / 2)
	end

	-- Restore previous color
	-- love.graphics.setColor(r, g, b, a)
	love.graphics.setColor(1, 1, 1)

	Base.draw(self)
end

function Button:update(dt)
	if not self.enabled then
		self.hovered = false
		return
	end

	local mx, my = love.mouse.getPosition()
	self.hovered = self:isMouseOver(mx, my)

	Base.update(self, dt)
end

function Button:mousepressed(mx, my, button)
	if Base.mousepressed(self, mx, my, button) then
		return true
	end

	if button == 1 and self:isMouseOver(mx, my) then
		self.pressed = true
		return true
	end
	return false
end

function Button:mousereleased(mx, my, button)
	if Base.mousereleased(self, mx, my, button) then
		return true
	end

	if button == 1 and self.pressed then
		self.pressed = false
		if self:isMouseOver(mx, my) then
			self.onClick(self)
			return true
		end
	end
	return false
end

function Button:setVariant(variant)
	self.variant = variant
	return self
end

function Button:setText(text)
	self.text = text
	return self
end

function Button:setIcon(icon, align, size)
	self.icon = icon
	self.iconAlign = align or "left"
	self.iconSize = size or self.iconSize
	return self
end

return Button
