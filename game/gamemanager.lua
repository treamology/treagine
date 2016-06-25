local class = require "treagine.lib.30log"

local FillViewport = require "treagine.render.fillviewport"
local DebugDrawSystem = require "treagine.system.debugdrawsystem"

local GameManager = class("GameManager")

-- callbacks
function GameManager:init(name)
	self.gameName = name or "Game"

	self.currentScreen = nil
	self.viewport = nil

	self.debugDraw = DebugDrawSystem()
	self.debugDraw.drawFPS = true
end

function GameManager:load()
	self:setViewport(FillViewport())
end

function GameManager:update(dt)
	if self.currentScreen then self.currentScreen:update(dt) end
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
	self.debugDraw.viewport = self.viewport
end
---------------

return GameManager