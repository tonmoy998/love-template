require("ui.color")
local App = {}
local Theme = require("ui.theme")
local vw
local vh
function App.load()
	vw, vh = 720, 1280
	App.bg = color.gray
end
function App.draw()
	love.graphics.setColor(App.bg)
	love.graphics.rectangle("fill", 0, 0, vw, vh)
	love.graphics.setColor(1, 1, 1, 1)
end
function App.update(dt) end

return App
