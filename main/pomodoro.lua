local Pomodoro = {}
local UI = require("ui")
local Arc = require("ui.components.arc")
local Alert = require("ui.components.alert")
local Button = require("ui.components.button")
local Theme = require("ui.theme")
local Flex = require("ui.flex")
local Text = require("ui.components.text")
local flux = require("ui.flux")
local json = require("lib.json")
local Setting = require("main.setting")

local scaleFactor, vw, vh
local timer, remaining, running, start, finished
local defaultFont, largeFont, showtime, arc
local currentState = "Focus"
local notify = false
local debug = false

-- Helper function to format time
local function formatTime(seconds)
	local displaySeconds = math.max(0, math.ceil(seconds))

	local min = math.floor(displaySeconds / 60)
	local sec = displaySeconds % 60

	return string.format("%02d:%02d", min, sec)
end

function Pomodoro.load()
	Pomodoro.bg = Theme.getColor("background")
	Pomodoro.userpref = {}
	scaleFactor = 2.0
	vw, vh = 720, 1600
	primary = Theme.getColor("primary")
	Pomodoro.os = love.system.getOS()
	Pomodoro.userpref = {
		focus = 25 * 60,
		short = 5 * 60,
		long = 15 * 60,
	}
	if Pomodoro.os == "Android" then
		Pomodoro.userpref.focus = Setting.userpref.focus * 60
		Pomodoro.userpref.short = Setting.userpref.short * 60
		Pomodoro.userpref.long = Setting.userpref.long * 60
	end
	defaultFont = love.graphics.newFont(16 * scaleFactor)
	largeFont = love.graphics.newFont(50 * scaleFactor)

	-- Fixed Flex: No more negative Y or massive H
	flex_buttons = Flex.new({
		x = 0,
		y = (50 * 2.5) + (20 * scaleFactor), -- Start where your background starts
		w = vw,
		h = 50 * scaleFactor + (10 * scaleFactor),
		direction = "row",
		gap = 8 * scaleFactor,
		align = "center",
		objects = {
			Button.new({
				text = "Pomodoro",
				w = 110 * scaleFactor,
				h = 50 * scaleFactor,
				font = defaultFont,
				onClick = function()
					timer = Pomodoro.userpref.focus
					remaining = timer
					start = false
					arc.progress = 0
					finished = false
					currentState = "Focus"
				end,
			}),
			Button.new({
				text = "Short Break",
				w = 115 * scaleFactor,
				h = 50 * scaleFactor,
				font = defaultFont,
				onClick = function()
					arc.progress = 0
					timer = Pomodoro.userpref.short
					remaining = timer
					start = false
					finished = false
					currentState = "Short Break"
				end,
			}),
			Button.new({
				text = "Long Break",
				w = 110 * scaleFactor,
				h = 50 * scaleFactor,
				font = defaultFont,
				onClick = function()
					arc.progress = 0
					timer = Pomodoro.userpref.long
					remaining = timer
					start = false
					currentState = "Long Break"
					finished = false
				end,
			}),
		},
	})

	timer = 0
	remaining = timer
	start = false
	progress = 0

	arc = Arc.new({
		x = (vw / 2),
		y = (vh / 2),
		r = 150 * scaleFactor,
		progress = 1,
		lineWidth = 15 * scaleFactor,
	})

	-- Text initialization with string conversion
	local timeStr = formatTime(remaining)
	showtime = Text.new({
		x = (vw / 2),
		y = (vh / 2),
		text = timeStr,
		font = largeFont,
	})
	-- Center the text object itself if your Text component supports it
	showtime.x = showtime.x - (largeFont:getWidth(timeStr) / 2)
	showtime.y = showtime.y - (largeFont:getHeight() / 2)

	stateW = defaultFont:getWidth(currentState)
	showState = Text.new({
		x = (vw / 2) - (stateW / 2),
		y = arc.y - arc.r - (60 * scaleFactor),
		text = currentState,
		font = defaultFont,
	})
	startButton = Button.new({
		x = (vw / 2) - (160 * scaleFactor) / 2,
		y = arc.y + arc.r + 50 * scaleFactor,
		w = 160 * scaleFactor,
		h = 50 * scaleFactor,
		text = "Start",
		font = defaultFont,
		zIndex = 10,
		onClick = function()
			if remaining == 0 then
				Alert.new({
					text = "Select your timer first!",
					w = (300 * scaleFactor),
					x = (vw / 2) - (300 * scaleFactor / 2),
					y = vh - (200 * scaleFactor),
					variant = "primary",
					font = defaultFont,
					buttonWidth = 120 * scaleFactor,
					buttonHeight = 40 * scaleFactor,
					duration = 10,
					padding = 20 * scaleFactor,
				})
				return
			end
			start = not start
			if startButton.text == "Start" then
				startButton.text = "Pause"
			else
				startButton.text = "Start"
			end
		end,
	})
	debugButton = Button.new({
		x = startButton.x,
		y = startButton.y + (70 * scaleFactor),
		w = startButton.w,
		h = startButton.h,
		variant = "danger",
		text = "Debug",
		onClick = function()
			timer = 5
			remaining = timer
			currentState = "Debug"
			start = true
			finished = false
			running = true
			notify = true
		end,
	})
end

function Pomodoro.update(dt)
	Pomodoro.userpref.focus = Setting.userpref.focus * 60
	Pomodoro.userpref.short = Setting.userpref.short * 60
	Pomodoro.userpref.long = Setting.userpref.long * 60
	stateW = defaultFont:getWidth(currentState)
	showState.x = (vw / 2) - (stateW / 2)
	showState.text = currentState
	showtime.text = timer
	if start and remaining > 0 then
		remaining = remaining - dt

		-- Update display text and progress arc
		local timeStr = formatTime(remaining)
		showtime.text = timeStr
		-- Keep text centered as numbers change width
		showtime.x = (vw / 2) - (largeFont:getWidth(timeStr) / 2)
	elseif remaining <= 0 and start then
		remaining = 0
		start = false
		remaining = 0
		finished = true
		notify = true
	end
	if remaining == 0 then
		arc.variant = "success"
		startButton.text = "Start"
	else
		arc.variant = "info"
	end
	progress = 1 - (remaining / timer)
	showtime.text = formatTime(remaining)
	arc.progress = progress
	if notify and finished then
		Alert.new({
			text = "Timer is finished",
			w = (300 * scaleFactor),
			x = (vw / 2) - (300 * scaleFactor / 2),
			y = vh - (200 * scaleFactor),
			variant = "success",
			font = defaultFont,
			buttonWidth = 120 * scaleFactor,
			buttonHeight = 40 * scaleFactor,
			duration = 10,
			padding = 20 * scaleFactor,
		})
		notify = false
		finished = false
	end
end

function Pomodoro.draw()
	-- love.graphics.setColor(primary[1], primary[2], primary[3])
	-- Using the same scale logic as Flex

	love.graphics.setColor(Pomodoro.bg[1], Pomodoro.bg[2], Pomodoro.bg[3])
	love.graphics.rectangle("fill", 0, (50 * scaleFactor), vw, vh)
	love.graphics.setColor(1, 1, 1, 1)
end

return Pomodoro
