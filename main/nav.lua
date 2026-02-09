local Image = require("ui.components.image")
local Button = require("ui.components.button")
local Theme = require("ui.theme")
local Nav = {}

local setting = require("main.setting")

local vw, vh = 720, 1600
local primary
function createScaledFont(scalefactor)
	local fontSize = vh * scalefactor
	return love.graphics.newFont(fontSize)
end

function Nav.load()
	scaleFactor = 2.5
	vm, vh = 720, 1600
	primary = Theme.getColor("primary")
	-- nav_icon = Image.new({
	-- 	x = 0,
	-- 	y = 20,
	-- 	w = 40 * scaleFactor,
	-- 	h = 40 * scaleFactor,
	-- 	src = "assets/love.png",
	-- 	scaleX = scaleFactor,
	-- 	scaleY = scaleFactor,
	-- })
	setting_icon = love.graphics.newImage("assets/setting.png")
	setting_button = Button.new({
		x = vw - (50 * scaleFactor),
		y = 10,
		w = 40 * scaleFactor,
		h = 40 * scaleFactor,
		icon = setting_icon,
		iconSize = 30 * scaleFactor,
		onClick = function()
			setting.open()
		end,
	})
	nav_icon = love.graphics.newImage("assets/love.png")
end

function Nav.draw()
	--nav background
	love.graphics.setColor(primary[1], primary[2], primary[3])
	love.graphics.rectangle("fill", 0, 0, vw, (50 * scaleFactor))
	love.graphics.setColor(1, 1, 1, 1)
	-- draw icon
	love.graphics.draw(nav_icon, 20, 20, nil, 0.3, 0.3)
end

function Nav.update(dt) end

return Nav
