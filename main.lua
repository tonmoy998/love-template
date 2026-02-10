_G.love = require("love")
local UI = require("ui")
local Theme = require("ui.theme")
local Button = require("ui.components.button")
local Alert = require("ui.components.alert")
local screen = require("lib.sunscreen")
local flux = require("ui.flux")
local App = require("main.main")
local push = require("lib.push")

-- Virtual width and height (your design resolution)
local vw, vh = 720, 1280
-- local vw, vh = 720, 1280
local windowWidth, windowHeight = love.window.getDesktopDimensions()
function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	push:setupScreen(vw, vh, windowWidth, windowHeight, { fullscreen = true })
end

function love.update(dt)
	flux.update(dt)
	local mx, my = love.mouse.getPosition()
	local vmx, vmy = screen:screenToGame(mx, my)
	UI.update(dt)
end

function love.draw()
	-- Draw virtual background
	-- love.graphics.setColor(primary[1], primary[2], primary[3], 0.4)
	-- love.graphics.rectangle("fill", 0, 0, vw, vh)

	push:start()
	-- Draw UI
	-- love.graphics.draw(love.graphics.newImage("floor.png"), 0, 0)
	UI.draw()
	push:finish()
end

function love.resize(w, h)
	return push:resize(w, h)
end

function love.mousepressed(x, y, button_type)
	local vmx, vmy = push:toGame(x, y)
	UI.mousepressed(vmx, vmy, button_type)
end

function love.mousereleased(x, y, button_type)
	-- local vmx, vmy = screen:screenToGame(x, y)
	--
	local vmx, vmy = push:toGame(x, y)
	UI.mousereleased(vmx, vmy, button_type)
end
