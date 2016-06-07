local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"

local Screen = class("Screen")

function Screen:init()
	self.backgroundColor = {0, 0, 0, 0}
end

function Screen:update()
	love.graphics.setBackgroundColor(self.backgroundColor)
	tiny.update(self.world, love.timer.getDelta() * TIME_SCALE)
end

return Screen