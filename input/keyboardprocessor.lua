local beholder = require "treagine.lib.beholder"

local KeyboardProcessor = {}

local keyState = {}
local prevKeyState = {}

local KEY_PRESSED = "KEY_PRESSED"
local KEY_HELD = "KEY_HELD"
local KEY_RELEASED = "KEY_RELEASED"

function KeyboardProcessor.keyPressed(scancode)
	keyState[scancode] = true
	beholder.trigger(KEY_PRESSED, scancode)
end

function KeyboardProcessor.keyReleased(scancode)
	keyState[scancode] = nil
	beholder.trigger(KEY_RELEASED, scancode)
end

function KeyboardProcessor.update()
	for k in pairs(keyState) do
		beholder.trigger(KEY_HELD, k)

		if prevKeyState[k] and keyState[k] then
			keyState[k] = false
		end
	end

	for k in pairs(keyState) do
		prevKeyState[k] = keyState[k]
	end
end

KeyboardProcessor.keyState = keyState

KeyboardProcessor.KEY_PRESSED = KEY_PRESSED
KeyboardProcessor.KEY_HELD = KEY_HELD
KeyboardProcessor.KEY_RELEASED = KEY_RELEASED

return KeyboardProcessor