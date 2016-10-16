-- Modifies functions that depend on window size so that they'll be easier to use with high-dpi displays.

local oldGetWidth = love.graphics.getWidth
local oldGetHeight = love.graphics.getHeight
local oldMousePosition = love.mouse.getPosition
local oldTouchPosition = love.touch.getPosition

local newGetWidth = function()
	local width = oldGetWidth() / love.window.getPixelScale()
	return width
end
local newGetHeight = function()
	local height = oldGetHeight() / love.window.getPixelScale()
	return height
end
local newMousePosition = function()
	local x, y = oldMousePosition()
	x = x / love.window.getPixelScale()
	y = y / love.window.getPixelScale()
	return x, y
end
local newTouchPosition = function(id)
	local x, y = oldTouchPosition(id)
	x = x / love.window.getPixelScale()
	y = y / love.window.getPixelScale()
	return x, y
end

love.graphics.getWidth = newGetWidth
love.graphics.getHeight = newGetHeight
love.mouse.getPosition = newMousePosition
love.touch.getPosition = newTouchPosition