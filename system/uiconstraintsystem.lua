local tiny = require "treagine.lib.tiny"
local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local vector = require "treagine.lib.vector"

local System = require "treagine.system.system"

local UIConstraintSystem = tiny.processingSystem(System:extend("UIConstraintSystem"))

function UIConstraintSystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAll("uiAnchorPoint", "uiOffset")
	self.runWhenPaused = true
end

function UIConstraintSystem:process(e, dt)
	local cw, ch, camx, camy
	if e.renderOnScreen then
		cw, ch = love.graphics.getWidth(), love.graphics.getHeight()
		camx, camy = 0, 0
	else
		cw, ch = self.screen.canvas:getDimensions()
		--camx, camy = self.screen.camera.x - cw / 2, self.screen.camera.y - ch / 2
		camx, camy = self.screen.viewport:unprojectLight(0, 0)
	end

	if e.resizeToFullscreen then
		for _, r in pairs(e.renderList) do
			r.size.x, r.size.y = cw, ch
		end
	end

	local x, y = cw * e.uiAnchorPoint.x, ch * e.uiAnchorPoint.y
	x = x + e.uiOffset.x + camx
	y = y + e.uiOffset.y + camy

	e.position.x = x
	e.position.y = y
end

return UIConstraintSystem