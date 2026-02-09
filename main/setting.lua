local setting = {}

local UI = require("ui")
local Window = require("ui.components.window")
local Button = require("ui.components.button")
local Text = require("ui.components.text")
local flux = require("ui.flux")
local json = require("lib.json")
local Alert = require("ui.components.alert")
local Toast = require("ui.components.toast")
local Theme = require("ui.theme")
local Togggle = require("ui.components.toggle")

local vw, vh
local scaleFactor = 2
local userpref
local bg

function setting.load()
	setting.os = love.system.getOS()
	bg = Theme.getColor("surface")
	setting.userpref = {
		focus = 25,
		short = 5,
		long = 15,
		theme = "light",
	}
	setting.userdata = love.filesystem.read("saves/userpref.json")
	if setting.userdata then
		local userdata = json.decode(setting.userdata)
		setting.userpref.focus = userdata.focus
		setting.userpref.short = userdata.short
		setting.userpref.long = userdata.long
		setting.userpref.theme = userdata.theme
	end

	setting.currentTheme = setting.userpref.theme
	UI.setTheme(setting.userpref.theme)
	vw, vh = 720, 1600
	setting.fontsm = love.graphics.newFont(10 * scaleFactor)
	setting.fontlg = love.graphics.newFont(40 * scaleFactor)
	setting.fontmd = love.graphics.newFont(16 * scaleFactor)

	setting.defaultFont = love.graphics.newFont(16 * scaleFactor)
	love.graphics.setFont(setting.defaultFont)
	setting.window = Window.new({
		x = 0,
		y = -1.5 * vh,
		w = vw,
		h = vh,
		border = false,
		zIndex = -100, -- start hidden
		onClick = function()
			print("Setting window was clicked")
		end,
		variant = "surface",
	})

	local crossIcon = love.graphics.newImage("assets/cross.png")

	setting.crossButton = Button.new({

		x = vw - (50 * scaleFactor) - 40,
		y = 10,
		w = 50 * scaleFactor,
		h = 50 * scaleFactor,
		icon = crossIcon,
		iconSize = 30 * scaleFactor,

		onClick = function()
			setting.close()
			print("Clicked")
		end,
	})
	setting.loadbutton = Button.new({
		x = (20 * scaleFactor),
		y = setting.crossButton.y + (50 * scaleFactor),
		text = "Save Data",
		variant = "info",
		w = (150 * scaleFactor),
		h = (50 * scaleFactor),
		font = setting.defaultFont,
		onClick = function()
			local jsonStr = json.encode(setting.userpref, { indent = true })
			if setting.os == "Android" then
				love.filesystem.createDirectory("saves")
				love.filesystem.write("saves/userpref.json", json.encode(setting.userpref))
				Toast.new({
					w = vw * 0.85,
					x = 10 * scaleFactor,
					y = vh - (250 * scaleFactor),
					title = "Android",
					text = "Config Loaded : " .. love.filesystem.getSaveDirectory(),
					variant = "info",
					fontsm = setting.fontmd,
					fontmd = setting.fontsm,
				})
			else
				love.filesystem.write("userpref.json", jsonStr)
				Toast.new({
					w = vw * 0.85,
					x = 10 * scaleFactor,
					y = vh - (250 * scaleFactor),
					title = "Setting",
					text = "Config Loaded : " .. love.filesystem.getSaveDirectory(),
					variant = "info",
					fontsm = setting.fontmd,
					fontmd = setting.fontsm,
				})
			end
		end,
	})
	setting.readbutton = Button.new({
		x = (20 * scaleFactor),
		y = setting.loadbutton.y + (80 * scaleFactor),
		text = "Read Data",
		w = (150 * scaleFactor),
		h = 50 * scaleFactor,
		font = setting.defaultFont,
		onClick = function()
			if setting.os == "Android" then
				local content, error = love.filesystem.read("saves/userpref.json")

				if content then
					local success, data = pcall(json.decode, content)

					if success and data then
						Toast.new({
							x = 10 * scaleFactor,
							y = vh - (150 * scaleFactor),
							title = "Loaded",
							text = "Focus: "
								.. data.focus
								.. "min, Short: "
								.. data.short
								.. "min, Long: "
								.. data.long
								.. "min",
							variant = "success",
							fontsm = setting.fontmd,
							fontmd = setting.fontsm,
						})

						-- Actually update the settings
						setting.userpref = data
					else
						Toast.new({
							x = 10 * scaleFactor,
							y = vh - (150 * scaleFactor),
							title = "Error",
							text = "Failed to parse JSON",
							variant = "danger",
							fontsm = setting.fontmd,
							fontmd = setting.fontsm,
						})
					end
				else
					Toast.new({
						x = 10 * scaleFactor,
						y = vh - (150 * scaleFactor),
						title = "Error",
						text = "File not found: " .. (error or "unknown"),
						variant = "danger",
						fontsm = setting.fontmd,
						fontmd = setting.fontsm,
					})
				end
			end
		end,
	})

	setting.window:add(setting.crossButton)
	setting.window:add(setting.loadbutton)
	setting.window:add(setting.readbutton)
	-- Focus setting
	showFocus = Text.new({
		x = setting.readbutton.x,
		w = 400 * scaleFactor,
		y = (280 * scaleFactor),
		text = "Focus :" .. setting.userpref.focus,
		font = setting.fontlg,
	})
	local upicon = love.graphics.newImage("assets/arrowup.png")
	local downicon = love.graphics.newImage("assets/arrowdown.png")
	increaseButton = Button.new({
		x = setting.readbutton.x + (230 * scaleFactor),
		y = (287 * scaleFactor),
		w = 30 * scaleFactor,
		h = 30 * scaleFactor,
		icon = upicon,
		iconSize = (30 * scaleFactor),
		onClick = function()
			setting.userpref.focus = setting.userpref.focus + 1
			print(setting.userpref.focus)
		end,
	})
	decreaseButton = Button.new({
		x = increaseButton.x + 50 * scaleFactor,
		y = (287 * scaleFactor),
		w = 30 * scaleFactor,
		h = 30 * scaleFactor,
		icon = downicon,
		iconSize = (30 * scaleFactor),
		onClick = function()
			setting.userpref.focus = setting.userpref.focus - 1
			print(setting.userpref.focus)
		end,
	})
	print(showFocus.y)
	setting.window:add(showFocus)
	setting.window:add(increaseButton)
	setting.window:add(decreaseButton)
	-- Short setting
	showShort = Text.new({
		x = setting.readbutton.x,
		w = 400 * scaleFactor,
		y = (335 * scaleFactor),
		text = "Short :" .. setting.userpref.short,
		font = setting.fontlg,
	})
	increaseButtonShort = Button.new({
		x = setting.readbutton.x + (230 * scaleFactor),
		y = (345 * scaleFactor),
		w = 30 * scaleFactor,
		h = 30 * scaleFactor,
		icon = upicon,
		iconSize = (30 * scaleFactor),
		onClick = function()
			setting.userpref.short = setting.userpref.short + 1
			print(setting.userpref.focus)
		end,
	})
	decreaseButtonShort = Button.new({
		x = increaseButton.x + 50 * scaleFactor,
		y = (345 * scaleFactor),
		w = 30 * scaleFactor,
		h = 30 * scaleFactor,
		icon = downicon,
		iconSize = (30 * scaleFactor),
		onClick = function()
			setting.userpref.short = setting.userpref.short - 1
			print(setting.userpref.focus)
		end,
	})
	setting.window:add(showShort)
	setting.window:add(increaseButtonShort)
	setting.window:add(decreaseButtonShort)
	-- Long
	showLong = Text.new({
		x = setting.readbutton.x,
		w = 400 * scaleFactor,
		y = (385 * scaleFactor),
		text = "Long :" .. setting.userpref.long,
		font = setting.fontlg,
	})
	increaseButtonLong = Button.new({
		x = setting.readbutton.x + (230 * scaleFactor),
		y = (398 * scaleFactor),
		w = 30 * scaleFactor,
		h = 30 * scaleFactor,
		icon = upicon,
		iconSize = (30 * scaleFactor),
		onClick = function()
			setting.userpref.long = setting.userpref.long + 1
			print(setting.userpref.focus)
		end,
	})
	decreaseButtonLong = Button.new({
		x = increaseButton.x + 50 * scaleFactor,
		y = (398 * scaleFactor),
		w = 30 * scaleFactor,
		h = 30 * scaleFactor,
		icon = downicon,
		iconSize = (30 * scaleFactor),
		onClick = function()
			setting.userpref.long = setting.userpref.long - 1
			print(setting.userpref.focus)
		end,
	})
	setting.window:add(showLong)
	setting.window:add(increaseButtonLong)
	setting.window:add(decreaseButtonLong)

	showtheme = Text.new({
		x = setting.readbutton.x,
		w = 400 * scaleFactor,
		y = (450 * scaleFactor),
		text = "Theme",
		font = setting.fontlg,
	})
	setting.window:add(showtheme)
	if setting.currentTheme == "dark" then
		themeState = true
	end
	toggle = Togggle.new({
		x = showtheme.x + 250 * scaleFactor,
		y = (460 * scaleFactor),
		w = 50 * scaleFactor,
		h = 30 * scaleFactor,
		state = themeState,
		onToggle = function()
			Toast.new({
				x = 10 * scaleFactor,
				y = vh * 0.75,
				title = "Warning",
				text = "Please restart your app for complete theme effect.",
				variant = "danger",
				fontsm = setting.fontsm,
				fontmd = setting.fontmd,
			})
			local current = Theme.current
			print(current)
			if current == "dark" then
				themeState = false
				UI.setTheme("light")
				setting.userpref.theme = "light"
				love.filesystem.write("saves/userpref.json", json.encode(setting.userpref))
			else
				UI.setTheme("dark")
				themeState = true
				setting.userpref.theme = "dark"
				love.filesystem.write("saves/userpref.json", json.encode(setting.userpref))
			end
		end,
	})
	if toggle.state then
		toggle.thumbX = toggle.x + toggle.w - toggle.radius + 10
	end
	setting.window:add(toggle)
end

-- 🔓 OPEN
function setting.open()
	-- set state instantly
	setting.window.zIndex = 100

	-- animate position only
	flux.to(setting.window, 0.35, { y = 0 }):ease("quadout")
end

-- 🔒 CLOSE
function setting.close()
	flux.to(setting.window, 0.35, { y = -1.5 * vh }):ease("quadout"):oncomplete(function()
		setting.window.zIndex = -100
	end)
end

function setting.update(dt)
	showFocus.y = setting.readbutton.y + (80 * scaleFactor)
	setting.userpref.focus = setting.userpref.focus
	setting.userpref.short = setting.userpref.short
	setting.userpref.long = setting.userpref.long
	setting.window:update(dt)

	setting.window.bg = bg
	showFocus.text = "Focus :" .. setting.userpref.focus
	showShort.text = "Short :" .. setting.userpref.short
	showLong.text = "Long :" .. setting.userpref.long
	setting.userpref.theme = setting.userpref.theme
end
function setting.draw() end

return setting
