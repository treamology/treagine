local beholder = require "treagine.lib.beholder"
local kp = require "treagine.input.keyboardprocessor"
local mp = require "treagine.input.mouseprocessor"

local InputEventProcessor = {}

local inputs = {}
local eventState = {}

local INPUT_EVENT = "INPUT_EVENT"
local INPUT_EVENT_PRESSED = "INPUT_EVENT_PRESSED"
local TRIGGER_EVENT = "TRIGGER_EVENT"

function InputEventProcessor.init(input)
	inputs = input

	beholder.observe(TRIGGER_EVENT, function(event, value)
		eventState[event] = value
	end) 
end

function InputEventProcessor.update()
	for k, v in pairs(inputs) do
		if kp.keyState[v] ~= nil then
			if kp.keyState[v] == true then
				beholder.trigger(INPUT_EVENT_PRESSED, k)
			end
			beholder.trigger(INPUT_EVENT, k)
			eventState[k] = true
		else
			eventState[k] = false
		end
	end
end

function InputEventProcessor.mouseUpdate()
	for k, v in pairs(inputs) do
		if string.find(v, "mouse") then
			local clipped = string.gsub(v, "mouse", "")
			local index = tonumber(clipped)
			local state = mp.mouseState[index]

			if state ~= nil then
				beholder.trigger(INPUT_EVENT, k)
				eventState[k] = true
			else
				eventState[k] = false
			end
		end
	end
end

InputEventProcessor.eventState = eventState

InputEventProcessor.INPUT_EVENT = INPUT_EVENT
InputEventProcessor.INPUT_EVENT_PRESSED = INPUT_EVENT_PRESSED
InputEventProcessor.TRIGGER_EVENT = TRIGGER_EVENT

return InputEventProcessor