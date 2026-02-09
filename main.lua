_G.love = require("love")
local UI = require("ui")
local Theme = require("ui.theme")
local Button = require("ui.components.button")
local Alert = require("ui.components.alert")
local screen = require("lib.sunscreen")
local flux = require("ui.flux")
local App = require("main.main")

-- Virtual width and height (your design resolution)
-- local vw, vh = 720, 1450
local vw, vh = 720, 1280
function love.load()
	-- Initialize Sunscreen for responsive screen
	screen:init({
		gameWidth = vw,
		gameHeight = vh,
		mode = "fit",
	})
	App.load()
end

function love.update(dt)
	flux.update(dt)
	local mx, my = love.mouse.getPosition()
	local vmx, vmy = screen:screenToGame(mx, my)
	App.update(dt)
	UI.update(dt)
end

function love.draw()
	-- Apply Sunscreen scaling
	screen:apply()

	-- Draw virtual background
	-- love.graphics.setColor(primary[1], primary[2], primary[3], 0.4)
	-- love.graphics.rectangle("fill", 0, 0, vw, vh)

	-- Draw UI
	App.draw()
	UI.draw()
end

function love.resize(w, h)
	screen:onResize(w, h)
end

function love.mousepressed(x, y, button_type)
	local vmx, vmy = screen:screenToGame(x, y)
	UI.mousepressed(vmx, vmy, button_type)
end

function love.mousereleased(x, y, button_type)
	local vmx, vmy = screen:screenToGame(x, y)
	UI.mousereleased(vmx, vmy, button_type)
end
