require("ui.color")

local Theme = {
	current = "dark",
	themes = {},
}

-- TOKYONIGHT LIGHT
Theme.themes.light = {
	-- Base
	background = rgba(245, 247, 250, 1),
	surface = rgba(255, 255, 255, 1),

	-- Text
	text = rgba(56, 58, 66, 1),
	textMuted = rgba(120, 122, 130, 1),
	textInverse = rgba(255, 255, 255, 1),

	-- Borders & shadow
	border = rgba(210, 215, 225, 1),
	borderActive = rgba(122, 162, 247, 1),
	shadow = rgba(0, 0, 0, 0.12),

	-- Semantic colors
	primary = rgba(122, 162, 247, 1), -- Tokyonight blue
	secondary = rgba(170, 170, 180, 1),

	success = rgba(158, 206, 106, 1), -- green
	warning = rgba(224, 175, 104, 1), -- amber
	danger = rgba(247, 118, 142, 1), -- red
	error = rgba(247, 118, 142, 1), -- alias
	info = rgba(125, 207, 255, 1), -- cyan

	disabled = rgba(180, 185, 195, 0.6),
}

-- TOKYONIGHT DARK
Theme.themes.dark = {
	-- Base
	background = rgba(26, 27, 38, 1),
	surface = rgba(36, 40, 59, 1),

	-- Text
	text = rgba(240, 240, 245, 1),
	textMuted = rgba(150, 160, 210, 1),
	textInverse = rgba(26, 27, 38, 1),

	-- Borders & shadow
	border = rgba(65, 72, 104, 1),
	borderActive = rgba(122, 162, 247, 1),
	shadow = rgba(0, 0, 0, 0.45),

	-- Semantic colors
	primary = rgba(122, 162, 247, 1),
	secondary = rgba(110, 114, 141, 1),

	success = rgba(158, 206, 106, 1),
	warning = rgba(224, 175, 104, 1),
	danger = rgba(247, 118, 142, 1),
	error = rgba(247, 118, 142, 1),
	info = rgba(125, 207, 255, 1),

	disabled = rgba(90, 94, 120, 0.6),
}

--------------------------------------------------
-- THEME API
--------------------------------------------------

function Theme.setCurrent(name)
	if Theme.themes[name] then
		Theme.current = name
		print("UI Theme:", name)
		return true
	end
	print("Theme not found:", name)
	return false
end

function Theme.get()
	return Theme.themes[Theme.current]
end

function Theme.add(name, themeData)
	Theme.themes[name] = themeData
end

function Theme.getColor(name)
	local theme = Theme.get()
	return theme[name] or rgba(255, 255, 255, 1)
end

function Theme.setColor(name)
	love.graphics.setColor(unpack(Theme.getColor(name)))
end

function Theme.getRGBA(name)
	local c = Theme.getColor(name)
	return c[1], c[2], c[3], c[4]
end

return Theme
