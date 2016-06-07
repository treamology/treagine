local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"

local Screen = class("Screen")

function Screen:init(viewport, systems)
	self.backgroundColor = {0, 0, 0, 0}
	self.systems = systems or {}
	self.viewport = viewport
end

function Screen:load()
	print("load")
	self.world = tiny.world()
	print(#self.systems)
	for _, v in ipairs(self.systems) do
		self.world:addSystem(v(self))
	end
end

function Screen:update()
	love.graphics.setBackgroundColor(self.backgroundColor)
	tiny.update(self.world, love.timer.getDelta() * TIME_SCALE)
end

return Screen