local tiny = require "treagine.lib.tiny"
local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local vector = require "treagine.lib.vector"

local UISystem = tiny.processingSystem(class("UISystem"))

function UISystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAll("interceptsMouse")
	self.runWhenPaused = true
end

function UISystem:update(dt)
	print("update")
end

return UISystem