-- UI/lib/fontmetrics.lua
local FontMetrics = {}

-- fallback to current font
local function getFont(font)
	return font or love.graphics.getFont()
end

-- =========================
-- Width of text
-- =========================
function FontMetrics.getWidth(text, font)
	font = getFont(font)
	return font:getWidth(tostring(text or ""))
end

-- =========================
-- Height of text (single line)
-- =========================
function FontMetrics.getHeight(font)
	font = getFont(font)
	return font:getHeight()
end

-- =========================
-- Width + Height
-- =========================
function FontMetrics.getSize(text, font)
	font = getFont(font)
	return font:getWidth(tostring(text or "")), font:getHeight()
end

-- =========================
-- Multiline height
-- =========================
function FontMetrics.getMultilineHeight(text, font)
	font = getFont(font)
	text = tostring(text or "")

	local lines = 1
	for _ in text:gmatch("\n") do
		lines = lines + 1
	end

	return lines * font:getHeight()
end

return FontMetrics
