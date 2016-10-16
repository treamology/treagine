--- Starting point for the game.
-- All initialization should be done here (prefereably a subclass).
-- Mostly responsible for loading and switching between screens.
-- @classmod GameManager

local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local gameconfig = require "treagine.config.gameconfig"

local FillViewport = require "treagine.render.fillviewport"

local GameManager = class("GameManager")

function GameManager:init(name)
	-- Perform fixes for retina.
	require "treagine.util.retinafixes"

	--- Name of the game that appears in the titlebar.
	-- @ivar gameName
	self.gameName = name or "Game"

	--- The currently loaded screen that hasn't been shown yet.
	self.queuedScreen = nil

	beholder.observe("SWITCH_SCREEN", function(screen)
		if self.currentScreen then
			self.currentScreen:unload()
		end
		self.currentScreen = screen
		self.currentScreen:load()
		self.currentScreen:start()
		beholder.trigger("SCREEN_SWITCHED", screen)
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
			beholder.trigger("SCREEN_SWITCHED", screen)
		end
	end)
end

function GameManager:load()
	if self.currentScreen then self.currentScreen:load() end
end

function GameManager:update(dt)
	if self.currentScreen and self.currentScreen.started then self.currentScreen:update(dt) end
end

function GameManager:draw()
	if self.currentScreen then self.currentScreen:draw() end
end

function GameManager:resize(w, h)
	if self.currentScreen then self.currentScreen:resize(w, h) end
end

return GameManager