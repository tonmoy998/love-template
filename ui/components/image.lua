local Base = require("ui.base")
local Manager = require("ui.manager")

local Image = setmetatable({}, { __index = Base })
Image.__index = Image

function Image.new(props)
	props = props or {}
	-- Initialize base component with x, y, w, h
	local self = setmetatable(Base.new("image", props.x or 0, props.y or 0, props.w or 100, props.h or 100), Image)

	-- Image Data
	self.imagePath = props.image or props.src
	self.image = nil
	self.scaleX = 1
	self.scaleY = 1
	self.alpha = props.alpha or 1

	-- Load and setup
	if self.imagePath then
		self:loadImage(self.imagePath)
	end

	Manager.add(self)
	return self
end

function Image:loadImage(path)
	-- Check if it's a string path or an already loaded Love Image object
	if type(path) == "string" then
		local success, result = pcall(love.graphics.newImage, path)
		if success then
			self.image = result
		else
			print("Error: Could not load image at " .. path)
			return
		end
	elseif type(path) == "userdata" and path:typeOf("Image") then
		self.image = path
	end

	self:updateScale()
end

function Image:updateScale()
	if not self.image then
		return
	end

	local imgW, imgH = self.image:getDimensions()
	-- Calculate scale to stretch image to the component's defined width and height
	self.scaleX = self.w / imgW
	self.scaleY = self.h / imgH
end

function Image:draw()
	if not self.visible or not self.image then
		return
	end

	local r, g, b, a = love.graphics.getColor()

	-- Respect parent scissoring (critical for Scroll boxes)
	local sx, sy, sw, sh = love.graphics.getScissor()
	love.graphics.intersectScissor(self.x, self.y, self.w, self.h)

	love.graphics.setColor(1, 1, 1, self.alpha)
	love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY)

	-- Restore previous scissor and color
	love.graphics.setScissor(sx, sy, sw, sh)
	love.graphics.setColor(r, g, b, a)
end

-- Update is empty because there are no hover/click interactions
function Image:update(dt) end

return Image
