local Base = require("ui.base")
local Theme = require("ui.theme")
local Manager = require("ui.manager")
local utf8 = require("utf8")
local flux = require("ui.flux")

local Input = setmetatable({}, { __index = Base })
Input.__index = Input

function Input.new(props)
	local self = setmetatable(Base.new("input"), Input)

	-- position & size
	self.x = props.x or 0
	self.y = props.y or 0
	self.w = props.w or 200
	self.h = props.h or 36

	-- text
	self.label = props.label or ""
	self.text = props.text or ""
	self.placeholder = props.placeholder or ""
	self.maxLength = props.maxLength

	-- font
	self.font = props.font or love.graphics.newFont(16)

	-- style
	self.padding = props.padding or 8
	self.borderWidth = props.borderWidth or 2
	self.borderRadius = props.borderRadius or 6
	self.variant = props.variant or "primary"

	-- state
	self.focused = false
	self.hovered = false
	self.enabled = true

	-- cursor
	self.cursorWidth = props.cursorWidth or 2
	self.cursorHeight = props.cursorHeight or (self.h * 0.6)
	self.cursorX = 0
	self.cursorY = 0
	self.cursorAlpha = 0
	self.cursorBg = Theme.getColor("primary")

	-- blinking cursor animation
	self.cursorloop = function()
		flux.to(self, 0.6, { cursorAlpha = 1 }):after(self, 0.6, { cursorAlpha = 0 }):oncomplete(self.cursorloop)
	end

	Manager.add(self)
	return self
end

function Input:isMouseOver(mx, my)
	return mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h
end

-- ================= DRAW =================

function Input:draw()
	love.graphics.setFont(self.font)

	local bg = self.enabled and Theme.getColor("surface") or Theme.getColor("disabled")
	local border = self.focused and Theme.getColor(self.variant) or Theme.getColor("border")
	local textColor = Theme.getColor("text")

	if self.hovered and not self.focused then
		bg = { bg[1] * 0.95, bg[2] * 0.95, bg[3] * 0.95, bg[4] }
	end

	-- background
	love.graphics.setColor(bg)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius)

	-- border
	love.graphics.setColor(border)
	love.graphics.setLineWidth(self.borderWidth)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.borderRadius)

	-- label
	if self.label ~= "" then
		love.graphics.setColor(textColor)
		love.graphics.print(self.label, self.x, self.y - self.font:getHeight() - 4)
	end

	-- text / placeholder
	love.graphics.setColor(textColor)
	local display = self.text ~= "" and self.text or self.placeholder
	love.graphics.print(display, self.x + self.padding, self.y + (self.h - self.font:getHeight()) / 2)

	-- cursor
	if self.focused then
		love.graphics.setColor(self.cursorBg[1], self.cursorBg[2], self.cursorBg[3], self.cursorAlpha)
		love.graphics.rectangle("fill", self.cursorX, self.cursorY, self.cursorWidth, self.cursorHeight)
	end

	love.graphics.setColor(1, 1, 1)
end

-- ================= UPDATE =================

function Input:update(dt)
	Base.update(self, dt)
	local mx, my = love.mouse.getPosition()
	self.hovered = self:isMouseOver(mx, my)

	local textWidth = self.font:getWidth(self.text)
	self.cursorX = self.x + self.padding + textWidth
	self.cursorY = self.y + (self.h - self.cursorHeight) / 2
end

-- ================= INPUT =================

function Input:mousepressed(x, y)
	if not self.enabled then
		flux:remove(self)
		return false
	end

	if self:isMouseOver(x, y) then
		self.focused = true
		Manager.setFocus(self)

		-- start cursor animation
		self.cursorAlpha = 1
		self.cursorloop()

		return true
	end

	flux:remove(self)
	self.focused = false
	self.cursorAlpha = 0
	return false
end

function Input:keypressed(key)
	if not self.focused or not self.enabled then
		return false
	end

	if key == "backspace" then
		local byteoffset = utf8.offset(self.text, -1)
		if byteoffset then
			self.text = self.text:sub(1, byteoffset - 1)
		end
	elseif key == "return" or key == "kpenter" then
		if self.onSubmit then
			self:onSubmit(self.text)
		end
	end

	return true
end

function Input:textinput(t)
	if not self.focused or not self.enabled then
		return false
	end
	if self.maxLength and utf8.len(self.text) >= self.maxLength then
		return true
	end

	self.text = self.text .. t
	return true
end

-- ================= API =================

function Input:getText()
	return self.text
end

function Input:setText(text)
	self.text = text or ""
end

return Input
