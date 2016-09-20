local beholder = require "treagine.lib.beholder"

local TouchProcessor = {}

local touches = {}

function TouchProcessor.touchPressed(id, x, y, dx, dy, pressure)
	touches[id] = {}
	touches[id].x = x
	touches[id].y = y
	touches[id].dx = dx
	touches[id].dy = dy
	touches[id].pressure = pressure
end

function TouchProcessor.touchMoved(id, x, y, dx, dy, pressure)
	touches[id].x = x
	touches[id].y = y
	touches[id].dx = dx
	touches[id].dy = dy
	touches[id].pressure = pressure
end

function TouchProcessor.touchReleased(id, x, y, dx, dy, pressure)
	touches[id] = nil
	beholder.trigger("touch_released", id, x, y)
end

function TouchProcessor.touchValid(id)
	local valid = false
	for oid in pairs(touches) do
		if not valid then valid = oid == id end
	end
	return valid
end

TouchProcessor.touches = touches

return TouchProcessor