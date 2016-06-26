local class = require "treagine.lib.30log"

local FillViewport = require "treagine.render.fillviewport"

local GameManager = class("GameManager")

-- callbacks
function GameManager:init(name)
	self.gameName = name or "Game"

	self.currentScreen = nil
	self.viewport = nil
end

function GameManager:load()
	self:setViewport(FillViewport())
end

function GameManager:update(dt)
	if self.currentScreen then self.currentScreen:update(dt) end
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