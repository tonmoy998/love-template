local ZIndex = require("ui.zIndex")

local Manager = {
	elements = {},
	toasts = {},
	arcs = {},
	alerts = {},
	theme = nil,
	focusedElement = nil,
	hoveredElement = nil,
	topElements = {}, -- cached top elements by type
}

-- Add element or toast/alert/arc
function Manager.add(element)
	if element.type == "toast" then
		table.insert(Manager.toasts, element)
	elseif element.type == "alert" then
		table.insert(Manager.alerts, element)
	elseif element.type == "arc" then
		table.insert(Manager.arcs, element)
	else
		table.insert(Manager.elements, element)
	end
	element.zIndex = element.zIndex or 1
	return element
end

-- Remove element
function Manager.remove(element)
	local list = Manager.elements
	for i, el in ipairs(list) do
		if el == element then
			table.remove(list, i)
			if Manager.focusedElement == element then
				Manager.focusedElement = nil
			end
			break
		end
	end
end

-- Remove finished toast
function Manager.removeToast(toast)
	for i = #Manager.toasts, 1, -1 do
		local t = Manager.toasts[i]
		if t.finished then
			table.remove(Manager.toasts, i)
		end
	end
end

function Manager.removeAlert(alert)
	for i, a in ipairs(Manager.alerts) do
		if a == alert then
			table.remove(Manager.alerts, i)
			return
		end
	end
end

-- Clear everything
function Manager.clear()
	Manager.elements = {}
	Manager.toasts = {}
	Manager.arcs = {}
	Manager.alerts = {}
	Manager.focusedElement = nil
	Manager.hoveredElement = nil
end

-- Set global theme
function Manager.setTheme(theme)
	Manager.theme = theme
end

-- Update all UI
function Manager.update(dt)
	local mx, my = love.mouse.getPosition()
	Manager.hoveredElement = nil

	-- Update toasts
	for i = #Manager.toasts, 1, -1 do
		local t = Manager.toasts[i]
		if t.update then
			t:update(dt)
		end
		if t.finished then
			Manager.removeToast(t)
		end
		if t.enabled and t.visible and t.isMouseOver and t:isMouseOver(mx, my) then
			Manager.hoveredElement = t
			return
		end
	end

	-- Update elements
	for i = #Manager.elements, 1, -1 do
		local e = Manager.elements[i]
		if e.update then
			e:update(dt)
		end
		if not Manager.hoveredElement and e.enabled and e.visible and e.isMouseOver and e:isMouseOver(mx, my) then
			Manager.hoveredElement = e
		end
	end

	-- Update arcs and alerts if needed
	for _, arc in ipairs(Manager.arcs) do
		if arc.update then
			arc:update(dt)
		end
	end
	for _, alert in ipairs(Manager.alerts) do
		if alert.update then
			alert:update(dt)
		end
	end

	-- Update cached top element
	Manager.updateTopElement()
end

-- Draw all UI in zIndex order
function Manager.draw()
	ZIndex:start()

	-- Combine all elements into one list for z-sorted drawing
	local allElements = {}

	for _, e in ipairs(Manager.elements) do
		if e.visible and not e.managed then
			table.insert(allElements, e)
		end
	end
	for _, t in ipairs(Manager.toasts) do
		if t.visible then
			t.zIndex = t.zIndex or 1000
			table.insert(allElements, t)
		end
	end
	for _, a in ipairs(Manager.alerts) do
		if a.visible then
			a.zIndex = a.zIndex or 1000
			table.insert(allElements, a)
		end
	end
	for _, arc in ipairs(Manager.arcs) do
		if arc.visible then
			arc.zIndex = arc.zIndex or 1
			table.insert(allElements, arc)
		end
	end

	-- Sort by zIndex descending
	table.sort(allElements, function(a, b)
		return (a.zIndex or 0) > (b.zIndex or 0)
	end)

	-- Draw in order
	for _, e in ipairs(allElements) do
		ZIndex:draw(e)
	end

	ZIndex:stop()
end

-- Cache the top element (highest zIndex)
function Manager.updateTopElement()
	local top = nil
	for _, e in ipairs(Manager.elements) do
		if not top or (e.zIndex or 0) > (top.zIndex or 0) then
			top = e
		end
	end
	for _, t in ipairs(Manager.toasts) do
		if not top or (t.zIndex or 0) > (top.zIndex or 0) then
			top = t
		end
	end
	for _, a in ipairs(Manager.alerts) do
		if not top or (a.zIndex or 0) > (top.zIndex or 0) then
			top = a
		end
	end
	for _, arc in ipairs(Manager.arcs) do
		if not top or (arc.zIndex or 0) > (top.zIndex or 0) then
			top = arc
		end
	end

	Manager.topElements[1] = top
end

function Manager.getTopElement()
	return Manager.topElements[1]
end

-- Mouse pressed events (top zIndex first)
function Manager.mousepressed(x, y, button)
	local allElements = {}

	-- Combine everything
	for _, e in ipairs(Manager.elements) do
		if e.mousepressed then
			table.insert(allElements, e)
		end
	end
	for _, t in ipairs(Manager.toasts) do
		if t.mousepressed then
			table.insert(allElements, t)
		end
	end
	for _, a in ipairs(Manager.alerts) do
		if a.mousepressed then
			table.insert(allElements, a)
		end
	end
	for _, arc in ipairs(Manager.arcs) do
		if arc.mousepressed then
			table.insert(allElements, arc)
		end
	end

	-- Sort descending zIndex
	table.sort(allElements, function(a, b)
		return (a.zIndex or 0) > (b.zIndex or 0)
	end)

	-- Process events
	for _, e in ipairs(allElements) do
		if e.mousepressed and e:mousepressed(x, y, button) then
			Manager.setFocus(e)
			return true
		end
	end

	Manager.setFocus(nil)
	return false
end

-- Mouse released
function Manager.mousereleased(x, y, button)
	local allElements = {}

	for _, e in ipairs(Manager.elements) do
		if e.mousereleased then
			table.insert(allElements, e)
		end
	end
	for _, t in ipairs(Manager.toasts) do
		if t.mousereleased then
			table.insert(allElements, t)
		end
	end
	for _, a in ipairs(Manager.alerts) do
		if a.mousereleased then
			table.insert(allElements, a)
		end
	end
	for _, arc in ipairs(Manager.arcs) do
		if arc.mousereleased then
			table.insert(allElements, arc)
		end
	end

	table.sort(allElements, function(a, b)
		return (a.zIndex or 0) > (b.zIndex or 0)
	end)

	for _, e in ipairs(allElements) do
		if e.mousereleased and e:mousereleased(x, y, button) then
			return true
		end
	end

	return false
end

-- Keyboard input
function Manager.keypressed(key)
	if Manager.focusedElement and Manager.focusedElement.keypressed then
		return Manager.focusedElement:keypressed(key)
	end
	return false
end

function Manager.textinput(t)
	if Manager.focusedElement and Manager.focusedElement.textinput then
		return Manager.focusedElement:textinput(t)
	end
	return false
end

-- Focus
function Manager.setFocus(element)
	if Manager.focusedElement and Manager.focusedElement.onBlur then
		Manager.focusedElement:onBlur()
	end

	Manager.focusedElement = element

	if element and element.onFocus then
		element:onFocus()
	end
end

-- Scroll / wheel events
function Manager.wheelmoved(x, y)
	for _, e in ipairs(Manager.elements) do
		if e.wheelmoved then
			e.wheelmoved(x, y)
		end
	end
end

return Manager
