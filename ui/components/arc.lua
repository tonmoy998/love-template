local Arc = {}
Arc.__index = Arc

local Manager = require("ui.manager")
local Theme = require("ui.theme")

function Arc.new(props)
	local self = setmetatable({
		x = props.x or 100,
		y = props.y or 100,
		r = props.r or 50,

		style = props.style or "open", -- "open" | "pie"
		variant = props.variant or "info",

		progress = props.progress or 0, -- 0 → 1
		startAngle = props.startAngle or -math.pi / 2,
		maxAngle = props.maxAngle or math.pi * 2,

		lineWidth = props.lineWidth or 3,
		visible = props.visible ~= false,
		bg = Theme.getColor("primary"),
		border = props.border or true,
		borderColor = props.borderColor or Theme.getColor("text"),
	}, Arc)

	Manager.add(self)
	return self
end

function Arc:draw()
	if not self.visible then
		return
	end
	if self.borderColor then
		love.graphics.setColor(self.borderColor)
		love.graphics.setLineWidth(self.lineWidth)
		love.graphics.circle("line", self.x, self.y, self.r)
	end

	local color = Theme.getColor(self.variant)
	love.graphics.setColor(color)
	love.graphics.setLineWidth(2 + self.lineWidth)
	love.graphics.arc(
		"line",
		self.style,
		self.x,
		self.y,
		self.r,
		self.startAngle,
		self.startAngle + self.maxAngle * self.progress
	)

	if self.bg then
		love.graphics.setLineWidth(self.lineWidth)
		love.graphics.setColor(self.bg[1], self.bg[2], self.bg[3])
		love.graphics.circle("fill", self.x, self.y, self.r)
	end
	love.graphics.setColor(1, 1, 1, 1)
end

function Arc:update()
	self.progress = self.progress
	self.x = self.x
	self.y = self.y
	self.r = self.r
	self.variant = self.variant
end

return Arc
