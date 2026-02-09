local Base = require("ui.base")
local Theme = require("ui.theme")
local Manager = require("ui.manager")
local flux = require("ui.flux")

local Progress = setmetatable({}, { __index = Base })
Progress.__index = Progress

function Progress.new(props)
	local self = setmetatable(Base.new("progress"), Progress)

	self.x = props.x or 0
	self.y = props.y or 0
	self.w = props.w or 200
	self.h = props.h or 16
	self.t = props.t or 0.8

	self.value = props.value or 0 -- animated value
	self.max = props.max or 100

	self.radius = props.radius or 6
	self.borderColor = props.borderColor or Theme.getColor("border")
	self.fillColor = props.fillColor or Theme.getColor(props.variant or "primary")

	Manager.add(self)
	return self
end

function Progress:draw()
	love.graphics.setColor(self.fillColor)
	love.graphics.rectangle("fill", self.x, self.y, self.w * (self.value / 100), self.h)

	love.graphics.setColor(self.borderColor)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

function Progress:update(dt)
	Base.update(self, dt)
end

function Progress:setValue(val)
	flux.to(self, self.t, { value = val })
end

return Progress
