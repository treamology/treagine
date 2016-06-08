local beholder = require "treagine.lib.beholder"
local sp = require "treagine.input.settingsprocessor"

local KeyboardProcessor = {}

local keyState = {}

local KEY_PRESSED = "KEY_PRESSED"
local KEY_HELD = "KEY_HELD"
local KEY_RELEASED = "KEY_RELEASED"
local INPUT_EVENT = "INPUT_EVENT"

function KeyboardProcessor.keyPressed(scancode)
	keyState[scancode] = true
	beholder.trigger(KEY_PRESSED, scancode)
end

function KeyboardProcessor.keyReleased(scancode)
	keyState[scancode] = nil
	beholder.trigger(KEY_RELEASED, scancode)
end

function KeyboardProcessor.update()
	for k in pairs(KeyboardProcessor.keyState) do
		beholder.trigger(KEY_HELD, k)

		keyState[k] = false
	end

	for k, v in pairs(sp.loadedSettings.input) do
		if keyState[v] ~= nil then
			beholder.trigger(INPUT_EVENT, k)
		end
	end
end

KeyboardProcessor.keyState = keyState

KeyboardProcessor.KEY_PRESSED = KEY_PRESSED
KeyboardProcessor.KEY_HELD = KEY_HELD
KeyboardProcessor.KEY_RELEASED = KEY_RELEASED
KeyboardProcessor.INPUT_EVENT = INPUT_EVENT

return KeyboardProcessor