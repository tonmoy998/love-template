local Base = require("ui.base")
local Manager = require("ui.manager")
local Theme = require("ui.theme")
local Button = require("ui.components.button")
local Window = require("ui.components.window")
local Text = require("ui.components.text")

local Alert = setmetatable({}, { __index = Base })
Alert.__index = Alert

function Alert.new(props)
	props = props or {}

	local sw, sh = love.graphics.getDimensions()
	local self = setmetatable(Base.new("alert", props.x, props.y, props.w, props.h), Alert)

	-- core
	self.w = props.w or 320
	self.h = props.h or 50
	self.x = props.x or (sw - self.w) / 2
	self.y = props.y or (sh - 150) / 2

	self.text = props.text or "Alert message"
	self.font = props.font or love.graphics.getFont()
	self.padding = props.padding or 16

	self.border = props.border or false
	self.borderAlpha = props.borderAlpha or 0.4
	self.borderWidth = props.lineWidth or 1

	self.visible = true
	self.duration = props.duration or 10
	self.zIndex = props.zIndex or 1000

	self.buttonWidth = props.buttonWidth or 100
	self.buttonHeight = props.buttonHeight or 40

	self.timer = 0

	-- measure text
	self.textHeight = self:getTextHeight()
	self.textWidth = self.font:getWidth(self.text)
	self.variant = props.variant or "danger"

	-- dynamic height
	self.h = self.padding * 3 + self.textHeight + self.buttonHeight

	self.window = Window.new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		padding = self.padding,
		border = self.border,
		zIndex = self.zIndex,
		variant = self.variant,
		onClick = function()
			print("Alert")
		end,
	})

	self.label = Text.new({
		x = 0,
		y = 0,
		w = self.w - self.padding * 2,
		text = self.text,
		font = self.font,
		align = "center",
	})

	-- button (centered)
	self.button = Button.new({
		w = self.buttonWidth,
		x = (self.w / 2) - (self.buttonWidth / 2),
		y = self.textHeight + 20,
		h = self.buttonHeight,
		variant = "disabled",
		text = "OK",
		zIndex = self.zIndex + 10,
		font = self.font,
		onClick = function()
			Manager.removeAlert(self)
			self.window:delete()
		end,
	})

	-- self.window:add(self.label)
	self.window:add(self.button)
	self.window:add(self.label)

	Manager.add(self)
	return self
end

function Alert:update(dt)
	Base.update(self, dt)
	self.label.x = self.x + 20
	self.label.y = self.y + 20
	self.textHeight = self:getTextHeight()
	self.h = self.textHeight + self.button.h + 2 * self.padding + 20
	self.window.h = self.h
	self.button.w = self.buttonWidth
	self.window.w = self.w + self.padding
	self.button.x = (self.window.w / 2) - (self.buttonWidth / 2) + self.padding

	self.timer = self.timer + dt
	if self.timer >= self.duration then
		self.visible = false
		Manager.removeAlert(self)
		Manager.remove(self.button)
		Manager.remove(self.window)
	end
end

function Alert:draw()
	if not self.visible then
		return
	end
end

function Alert:getTextHeight()
	local font = self.font or love.graphics.getFont()
	local _, lines = font:getWrap(self.text, self.w - self.padding * 2)
	return #lines * font:getHeight()
end

return Alert
