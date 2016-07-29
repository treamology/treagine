local beholder = require "treagine.lib.beholder"
local kp = require "treagine.input.keyboardprocessor"
local mp = require "treagine.input.mouseprocessor"

local InputEventProcessor = {}

local inputs = {}
local eventState = {}

local INPUT_EVENT = "INPUT_EVENT"

function InputEventProcessor.init(input)
	inputs = input
end

function InputEventProcessor.update()
	for k, v in pairs(inputs) do

		local state

		if string.find(v, "mouse") then
			local clipped = string.gsub(v, "mouse", "")
			local index = tonumber(clipped)
			state = mp.mouseState[index]
		else
			state = kp.keyState[v]
		end

		if state ~= nil then
			beholder.trigger(INPUT_EVENT, k)
			eventState[k] = true
		else
			eventState[k] = false
		end
	end
end

InputEventProcessor.eventState = eventState

InputEventProcessor.INPUT_EVENT = INPUT_EVENT

return InputEventProcessor