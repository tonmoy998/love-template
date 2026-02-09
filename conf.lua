function love.conf(t)
	t.window.title = "Pomodoro"
	t.window.width = 1080
	t.window.height = 2400
	t.window.fullscreen = true
	t.identity = "pomodorotimer" -- or whatever name you want
	t.externalstorage = true -- Important for Android
end
