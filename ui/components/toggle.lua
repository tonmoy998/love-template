local Base = require("ui.base")
local Manager = require("ui.manager")
local theme = require("ui.theme")
local flux = require("ui.flux")

local ToggleButton = setmetatable({}, { __index = Base })
ToggleButton.__index = ToggleButton

function ToggleButton.new(props)
	local self = setmetatable(Base.new("toggle", props.x, props.y, props.w, props.h), ToggleButton)

	-- Configuration
	self.state = props.state or false -- on/off
	self.onToggle = props.onToggle or function() end

	-- Colors
	self.bgColor = props.bgColor or theme.getColor("primary")
	self.offColor = props.offColor or theme.getColor("disabled")
	self.thumbColor = props.thumbColor or theme.getColor("text")
	-- Dimensions
	self.w = props.w or 60
	self.h = props.h or 30
	self.radius = props.radius or self.h / 2
	self.thumbRadius = props.thumbRadius or self.radius - 2
	self.padding = props.padding or 2
	self.animationTime = props.animationTime or 0.2

	-- Correct initial thumb position
	self.thumbX = self.x + (self.state and (self.w - self.radius) or self.radius)

	Manager.add(self)
	return self
end

-- Draw toggle button
function ToggleButton:draw()
	if not self.visible then
		return
	end

	local r, g, b, a = love.graphics.getColor()

	-- Background
	love.graphics.setColor(self.state and self.bgColor or self.offColor)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.radius, self.radius)

	-- Thumb
	love.graphics.setColor(self.thumbColor)
	love.graphics.circle("fill", self.thumbX, self.y + self.h / 2, self.thumbRadius)

	love.graphics.setColor(r, g, b, a)

	Base.draw(self)
end

-- Update animation
function ToggleButton:update(dt)
	Base.update(self, dt)
	local mx, my = love.mouse.getPosition()
	self.hovered = self:isMouseOver(mx, my)

	-- Flux animation update
end

-- Mouse pressed
function ToggleButton:mousepressed(mx, my, button)
	if button == 1 and self:isMouseOver(mx, my) then
		self.state = not self.state
		self:onToggle(self.state)

		-- Animate thumb
		local targetX = self.x + (self.state and (self.w - self.radius) or self.radius)
		flux.to(self, self.animationTime, { thumbX = targetX }):ease("quadout")
		return true
	end
	return false
end

function ToggleButton:onToggle(state)
	if self.onToggle then
		self.state = self.onToggle(state)
	end
end

return ToggleButton
