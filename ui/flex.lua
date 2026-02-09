local Base = require("ui.base")
local Manager = require("ui.manager")

local Flex = setmetatable({}, { __index = Base })
Flex.__index = Flex

function Flex.new(props)
	local self = setmetatable(Base.new("flex", props.x or 0, props.y or 0, props.w or 0, props.h or 0), Flex)

	self.children = props.objects or {} -- list of UI objects
	self.direction = props.direction or "row" -- "row" or "column"
	self.gap = props.gap or 0
	self.align = props.align or "start" -- "start", "center", "end" cross-axis
	self.dynamic = true -- will recalc positions dynamically

	Manager.add(self)
	return self
end

-- Update positions of children
function Flex:updateLayout()
	if not self.dynamic then
		return
	end

	local offsetX, offsetY = self.x, self.y

	if self.direction == "row" then
		-- calculate total width for alignment
		local totalW = 0
		for _, child in ipairs(self.children) do
			totalW = totalW + child.w
		end
		totalW = totalW + self.gap * (#self.children - 1)

		local startX = offsetX
		if self.align == "center" then
			startX = offsetX + (self.w - totalW) / 2
		elseif self.align == "end" then
			startX = offsetX + (self.w - totalW)
		end

		local xPos = startX
		for _, child in ipairs(self.children) do
			child.x = xPos
			-- center cross-axis vertically
			child.y = self.y + (self.h - child.h) / 2
			xPos = xPos + child.w + self.gap
		end
	elseif self.direction == "column" then
		-- calculate total height for alignment
		local totalH = 0
		for _, child in ipairs(self.children) do
			totalH = totalH + child.h
		end
		totalH = totalH + self.gap * (#self.children - 1)

		local startY = offsetY
		if self.align == "center" then
			startY = offsetY + (self.h - totalH) / 2
		elseif self.align == "end" then
			startY = offsetY + (self.h - totalH)
		end

		local yPos = startY
		for _, child in ipairs(self.children) do
			child.y = yPos
			-- center cross-axis horizontally
			child.x = self.x + (self.w - child.w) / 2
			yPos = yPos + child.h + self.gap
		end
	end
end

function Flex:update(dt)
	self:updateLayout() -- update layout dynamically each frame

	for _, child in ipairs(self.children) do
		if child.update then
			child:update(dt)
		end
	end

	Base.update(self, dt)
end

function Flex:draw()
	for _, child in ipairs(self.children) do
		if child.draw then
			child:draw()
		end
	end

	Base.draw(self)
end

function Flex:getSize()
	-- Calculate width and height dynamically from children
	local totalW, totalH = 0, 0
	local count = #self.children
	local gap = self.gap * math.max(0, count - 1)

	if self.direction == "row" then
		-- sum widths
		for _, child in ipairs(self.children) do
			totalW = totalW + child.w
			totalH = math.max(totalH, child.h)
		end
		totalW = totalW + gap
	elseif self.direction == "column" then
		-- sum heights
		for _, child in ipairs(self.children) do
			totalH = totalH + child.h
			totalW = math.max(totalW, child.w)
		end
		totalH = totalH + gap
	end

	return totalW, totalH
end

return Flex
