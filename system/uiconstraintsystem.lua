local tiny = require "treagine.lib.tiny"
local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local vector = require "treagine.lib.vector"

local UIConstraintSystem = tiny.processingSystem(class("UIConstraintSystem"))

function UIConstraintSystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAll("uiAnchorPoint", "uiOffset")
end

function UIConstraintSystem:process(e, dt)
	local cw, ch = self.screen.canvas:getDimensions()
	local camx, camy = self.screen.camera.x, self.screen.camera.y

	local x, y = cw * e.uiAnchorPoint.x, ch * e.uiAnchorPoint.y
	x = x + e.uiOffset.x + camx - cw / 2
	y = y + e.uiOffset.y + camy - ch / 2

	e.position.x = x
	e.position.y = y
end

return UIConstraintSystem