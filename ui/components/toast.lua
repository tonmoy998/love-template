local Base = require("ui.base")
local Manager = require("ui.manager")
local theme = require("ui.theme")
local flux = require("ui.flux")

local Toast = setmetatable({}, { __index = Base })
Toast.__index = Toast

function Toast.new(props)
	local sw = love.graphics.getWidth()

	local self = setmetatable(Base.new("toast"), Toast)

	-- layout
	self.w = props.w or math.min(sw * 0.9, 420)
	self.x = props.x or (sw - self.w) / 2
	self.y = props.y or 20

	self.padding = props.padding or 12
	self.gap = props.gap or 15
	self.iconsize = props.iconsize or 28
	self.finished = props.finished or false

	-- border
	self.border = props.border or 2
	self.borderOpacity = props.borderOpacity or 0.6
	self.borderRadius = props.borderRadius or 0

	-- content
	self.title = props.title or "Title"
	self.message = props.text or "This is a test message"
	self.variant = props.variant or "primary"

	-- colors
	self.bgcolor = props.bgcolor or theme.getColor(self.variant)
	self.textcolor = props.textcolor or theme.getColor("text")

	-- fonts
	self.fontTitle = props.fontmd or love.graphics.newFont(18)
	self.fontBody = props.fontsm or love.graphics.newFont(14)

	-- icon
	self.icon = props.icon or love.graphics.newImage("ui/components/icons/warning.png")

	-- timing
	self.duration = props.duration or 3

	-- progress bar
	self.ph = props.ph or 6
	self.pbg = props.pbg or { 1, 1, 1 }

	-- animation state
	self.progress = 1
	self.alpha = 1

	self.visible = props.visible ~= false
	self.enabled = props.enabled ~= false

	self:layout()

	-- progress + fade animation
	flux.to(self, self.duration, { progress = 0 }):ease("linear"):oncomplete(function()
		flux.to(self, 0.3, { alpha = 0 }):ease("quadout"):oncomplete(function()
			self.finished = true
		end)
	end)
	self.zIndex = props.zIndex or 1000

	Manager.add(self)
	return self
end

function Toast:layout()
	if not self.visible then
		return
	end
	local pad = self.padding

	-- icon
	self.iconX = self.x + pad
	self.iconY = self.y + pad

	-- text area
	self.textX = self.iconX + self.iconsize + self.gap
	self.textW = self.w - (self.textX - self.x) - pad

	-- title height
	love.graphics.setFont(self.fontTitle)
	local titleH = self.fontTitle:getHeight()

	-- message height (wrapped)
	love.graphics.setFont(self.fontBody)
	local _, lines = self.fontBody:getWrap(self.message, self.textW)
	local messageH = #lines * self.fontBody:getHeight()

	self.titleY = self.y + pad
	self.messageY = self.titleY + titleH + 4

	-- responsive height
	self.h = math.max(self.iconsize + pad * 2, pad + titleH + messageH + pad)
end

function Toast:update(dt)
	Base.update(self, dt)
	-- responsive width on resize
	local sw = love.graphics.getWidth()
	local newW = math.min(sw * 0.9, 420)

	if newW ~= self.w then
		self.w = newW
		self.x = (sw - self.w) / 2
		self:layout()
	end
end

function Toast:draw()
	if not self.visible then
		return
	end
	-- background
	love.graphics.setColor(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3], self.alpha)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.borderRadius, self.borderRadius)

	-- border
	love.graphics.setColor(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3], self.borderOpacity * self.alpha)
	love.graphics.setLineWidth(4 + self.border)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.borderRadius, self.borderRadius)

	-- icon
	if self.icon then
		local iw = self.icon:getWidth()
		local scale = self.iconsize / iw

		love.graphics.setColor(1, 1, 1, self.alpha)
		love.graphics.draw(self.icon, self.iconX, self.iconY, 0, scale, scale)
	end

	-- title
	love.graphics.setFont(self.fontTitle)
	love.graphics.setColor(self.textcolor[1], self.textcolor[2], self.textcolor[3], self.alpha)
	love.graphics.print(self.title, self.textX, self.titleY)

	-- message
	love.graphics.setFont(self.fontBody)
	love.graphics.printf(self.message, self.textX, self.messageY, self.textW)

	-- progress bar (top)
	local pw = self.w * self.progress
	love.graphics.setColor(self.pbg[1], self.pbg[2], self.pbg[3], self.alpha)
	love.graphics.rectangle("fill", self.x, self.y, pw, self.ph, self.borderRadius, self.borderRadius)

	love.graphics.setColor(1, 1, 1)
end

return Toast
