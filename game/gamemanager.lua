local class = require "treagine.lib.30log"

local FillViewport = require "treagine.render.fillviewport"
local DebugDrawSystem = require "treagine.system.debugdrawsystem"

local GameManager = class("GameManager")

-- callbacks
function GameManager:init(name)
	self.name = name or "Game"

	self.currentScreen = nil
	self.viewport = nil

	self.debugDraw = DebugDrawSystem()
	self.debugDraw.drawFPS = true
end

function GameManager:load()
	self:setViewport(FillViewport(love.graphics.getWidth(), love.graphics.getHeight()))
end

function GameManager:update(dt)
	self.currentScreen:update(dt)
	self.debugDraw:draw()
end

function GameManager:resize()
	if self.viewport then self.viewport:recalculate() end
end
---------------

-- getters/setters
function GameManager:setViewport(viewport)
	self.viewport = viewport
	self.viewport:recalculate()
end
---------------

return GameManager