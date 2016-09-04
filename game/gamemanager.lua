local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"

local FillViewport = require "treagine.render.fillviewport"

local GameManager = class("GameManager")

function GameManager:init(name)
	self.gameName = name or "Game"

	self.queuedScreen = nil

	beholder.observe("SWITCH_SCREEN", function(screen)
		if self.currentScreen then
			self.currentScreen:unload()
		end
		self.currentScreen = screen
		self.currentScreen:load()
		self.currentScreen:start()
	end)
	beholder.observe("UNLOAD_CURRENT_SCREEN", function()
		self.currentScreen:unload()
		self.currentScreen = nil
	end)
	beholder.observe("QUEUE_SCREEN", function(screen)
		self.queuedScreen = screen
		self.queuedScreen:load()
	end)
	beholder.observe("START_SCREEN", function()
		if self.queuedScreen then
			self.currentScreen = screen
			self.currentScreen:start()
			self.queuedScreen = nil
		end
	end)
end

function GameManager:load()
	if self.currentScreen then self.currentScreen:load() end
end

function GameManager:update(dt)
	if self.currentScreen and self.currentScreen.started then self.currentScreen:update(dt) end
end

function GameManager:resize(w, h)
	if self.currentScreen then self.currentScreen:resize(w, h) end
end

return GameManager