local class = require "treagine.lib.30log"

local FillViewport = require "treagine.render.fillviewport"
local DebugDrawSystem = require "treagine.system.debugdrawsystem"

local GameManager = class("GameManager")

-- callbacks
function GameManager:init()
	self.currentScreen = nil
	self.viewport = nil
	self.debugDraw = DebugDrawSystem()
end

function GameManager:load()
	self:setViewport(FillViewport())
end

function GameManager:update(dt)
	self.currentScreen.update(dt)
	self.debugDraw:draw()
end

function GameManager:resize()
	if self.viewport then self.viewport:resize() end
end
---------------

-- getters/setters
function GameManager:setViewport(viewport)
	self.viewport = viewport
	self.viewport:recalculate()
end
---------------

return GameManager