local UI = {
	_VERSION = "1.0.0",
	_DESCRIPTION = "Modular UI Library for Love2D",
}

local path = (...):gsub("%.init$", "")

-- Load core modules

UI.Base = require(path .. ".base")
UI.Manager = require(path .. ".manager")
UI.Theme = require(path .. ".theme")

-- Load components
UI.Button = require(path .. ".components.button")
UI.Input = require(path .. ".components.input")
UI.Text = require(path .. ".components.text")
UI.Progress = require(path .. ".components.progress")
UI.Toast = require(path .. ".components.toast")
UI.Window = require(path .. ".components.window")

-- Initialize manager with theme
UI.Manager.setTheme(UI.Theme)

-- Convenience functions
function UI.setTheme(themeName)
	UI.Theme.setCurrent(themeName)
end

function UI.addTheme(name, themeData)
	UI.Theme.add(name, themeData)
end

function UI.draw()
	UI.Manager.draw()
end

function UI.update(dt)
	UI.Manager.update(dt)
end

function UI.mousepressed(x, y, button)
	UI.Manager.mousepressed(x, y, button)
end

function UI.mousereleased(x, y, button)
	UI.Manager.mousereleased(x, y, button)
end

function UI.keypressed(key)
	UI.Manager.keypressed(key)
end

function UI.textinput(t)
	UI.Manager.textinput(t)
end

return UI
