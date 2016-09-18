local beholder = require "treagine.lib.beholder"

local MouseProcessor = {}

local mouseState = {}
local prevJustPressed = {}

local MOUSE_PRESSED = "MOUSE_PRESSED"
local MOUSE_HELD = "MOUSE_HELD"
local MOUSE_RELEASED = "MOUSE_RELEASED"

function MouseProcessor.mousePressed(x, y, button, istouch)
	mouseState[button] = {}
	mouseState[button].x = x
	mouseState[button].y = y
	mouseState[button].istouch = istouch
	mouseState[button].justPressed = true

	beholder.trigger(MOUSE_PRESSED, button, istouch, x, y)
end

function MouseProcessor.mouseReleased(x, y, button, istouch)
	mouseState[button] = nil
	beholder.trigger(MOUSE_RELEASED, button, istouch, x, y)
end

function MouseProcessor.update()
	for k, v in pairs(MouseProcessor.mouseState) do
		local ux, uy = love.mouse.getPosition()

		beholder.trigger(MOUSE_HELD, k, v.istouch, ux, uy)

		if prevJustPressed[k] then
			mouseState[k].justPressed = false
		end

		mouseState[k].x = ux
		mouseState[k].u = uy

		prevJustPressed[k] = mouseState[k].justPressed
	end
end

MouseProcessor.mouseState = mouseState

MouseProcessor.MOUSE_PRESSED = MOUSE_PRESSED
MouseProcessor.MOUSE_HELD = MOUSE_HELD
MouseProcessor.MOUSE_RELEASED = MOUSE_RELEASED

return MouseProcessor