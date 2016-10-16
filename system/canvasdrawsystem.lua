local tiny = require "treagine.lib.tiny"
local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local vector = require "treagine.lib.vector"

local System = require "treagine.system.system"

local CanvasDrawSystem = tiny.processingSystem(System:extend("CanvasDrawSystem"))

function CanvasDrawSystem:init(screen)
	CanvasDrawSystem.super.init(self, screen)

	self.filter = tiny.requireAll("draw")
end

function CanvasDrawSystem:process(e)
	e:draw(self.screen)
end

return CanvasDrawSystem