local Base = require("ui.base")
local Manager = require("ui.manager")
local Window = require("ui.components.window")
local Button = require("ui.components.button")
local flux = require("ui.flux")
local FontMatrics = require("ui.fontmetrics")
local Tab = setmetatable({}, { __index = Base })
Tab.__index = Tab

function Tab.new(props)
	local self = setmetatable(Base.new("tab", props.x, props.y, props.w, props.h), Tab)

	self.x = props.x or 100
	self.y = props.y or 100
	self.w = props.w or 400
	self.h = props.h or 400
	self.gap = props.gap or 5
	self.border = props.border ~= false
	self.font = props.font or love.graphics.getFont()

	self.window = Window.new({
		x = self.x,
		y = self.y,
		w = self.w,
		h = self.h,
		border = self.border,
	})

	self.currentIndex = 1
	self.totalIndex = 0
	self.tabs = {} -- store tab windows
	self.buttons = {}
	self.animTime = 0.30

	Manager.add(self)
	return self
end

function Tab:addtab(label, objects)
	self.totalIndex = self.totalIndex + 1
	local index = self.totalIndex

	-- DEFAULT ACTIVE TAB (ONLY ONCE)
	if self.currentIndex == 0 then
		self.currentIndex = 1
	end

	local button = Button.new({
		x = self.x + (index - 1) * 80,
		y = self.y,
		padding = 10,
		variant = "primary",
		text = label,
		onClick = function()
			if self.currentIndex == index then
				return
			end

			local prev = self.tabs[self.currentIndex]
			local next = self.tabs[index]

			self.currentIndex = index

			next.zIndex = 10
			next.alpha = 0
			next.x = self.x + 20

			flux.to(next, self.animTime, {
				x = self.x,
				alpha = 1,
			}):ease("quadout")

			if prev then
				flux.to(prev, self.animTime, {
					x = self.x,
					alpha = 0,
				})
					:ease("quadin")
					:oncomplete(function()
						prev.zIndex = 1
					end)
			end
		end,
	})
	local buttonW = button.w
	local buttonH = button.h
	local textW = FontMatrics.getWidth(button.text, self.font)
	local textH = FontMatrics.getHeight(self.font)
	if buttonW < textW or (buttonW - textW) <= 10 then
		button.w = textW + 20
	elseif buttonH < textH or (buttonH - textH) <= 10 then
		button.h = textH + 20
	end

	table.insert(self.buttons, button)
	local window = Window.new({
		x = self.x,
		y = button.y + button.h,
		w = self.w,
		h = self.h - button.h,
		border = true,
		bg = rgba(120, 120, 120),
		zIndex = 1,
	})

	window.alpha = 0
	self.tabs[index] = window

	for _, element in ipairs(objects or {}) do
		element.lx = element.x
		element.ly = element.y
		window:addChild(element)
	end

	self:_syncTabs()
	self:_layoutButtons()
end

function Tab:_syncTabs()
	for i, win in ipairs(self.tabs) do
		if i == self.currentIndex then
			win.zIndex = 10
			win.alpha = 1
			win.x = self.x
		else
			win.zIndex = 1
			win.alpha = 0
		end
	end
end

function Tab:update(dt)
	Base.update(self, dt)
end

function Tab:_layoutButtons()
	local x = self.x

	for i, btn in ipairs(self.buttons) do
		btn.x = x
		btn.y = self.y
		x = x + btn.w + self.gap
	end
end

return Tab
