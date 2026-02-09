local Base = require("ui.base")
local Manager = require("ui.manager")
local flux = require("ui.flux")

local ImageButton = setmetatable({}, { __index = Base })
ImageButton.__index = ImageButton

function ImageButton.new(props)
	props = props or {}
	-- Initialize with provided w and h
	local self =
		setmetatable(Base.new("imagebutton", props.x or 0, props.y or 0, props.w or 100, props.h or 100), ImageButton)

	-- Image Setup
	self.imagePath = props.image or props.imagePath or props.src
	self.image = nil
	self.imageScale = { x = 1, y = 1 }

	-- Load image if path provided
	if self.imagePath then
		self:loadImage(self.imagePath)
	end

	-- Opacity only (No BG/Border logic)
	self.imageAlpha = props.imageAlpha or 1
	self.currentAlpha = self.imageAlpha

	-- State
	self.hover = false
	self.active = false

	-- Callback
	self.onClick = props.onClick

	Manager.add(self)
	return self
end

function ImageButton:loadImage(path)
	local success, result = pcall(love.graphics.newImage, path)
	if success then
		self.image = result
		self:calculateImageScale()
	else
		print("Error loading image: " .. tostring(path))
	end
end

function ImageButton:calculateImageScale()
	if not self.image then
		return
	end

	local imgW, imgH = self.image:getDimensions()

	-- STRETCH: Forces the image to match the component's W and H exactly
	self.imageScale.x = self.w / imgW
	self.imageScale.y = self.h / imgH
end

function ImageButton:update(dt)
	local mx, my = love.mouse.getPosition()

	-- Update hover state based on the current world position (supports scrolling)
	self.hover = mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h
end

function ImageButton:draw()
	if not self.visible or not self.image then
		return
	end

	local r, g, b, a = love.graphics.getColor()

	-- We use intersectScissor so that if this is in a ScrollBox,
	-- it respects the parent's boundaries.
	local sx, sy, sw, sh = love.graphics.getScissor()
	love.graphics.intersectScissor(self.x, self.y, self.w, self.h)

	love.graphics.setColor(1, 1, 1, self.currentAlpha)
	love.graphics.draw(self.image, self.x, self.y, 0, self.imageScale.x, self.imageScale.y)

	love.graphics.setScissor(sx, sy, sw, sh)
	love.graphics.setColor(r, g, b, a)
end

function ImageButton:mousepressed(mx, my, button)
	-- Click logic: only triggers if mouse is within the stretched bounds
	if button == 1 and self.hover then
		self.active = true
	end
end

function ImageButton:mousereleased(mx, my, button)
	if button == 1 and self.active then
		self.active = false

		-- Final check that mouse is still over the button on release
		if self.hover and self.onClick then
			self.onClick(self)
		end
	end
end

return ImageButton
