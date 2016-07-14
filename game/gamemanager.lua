local class = require "treagine.lib.30log"

local FillViewport = require "treagine.render.fillviewport"

local GameManager = class("GameManager")

function GameManager:init(name)
	self.gameName = name or "Game"
end

function GameManager:load()
	if self.currentScreen then self.currentScreen:load() end
end

function GameManager:update(dt)
	if self.currentScreen then self.currentScreen:update(dt) end
end

function GameManager:resize(w, h)
	if self.currentScreen then self.currentScreen:resize(w, h) end
end

return GameManager