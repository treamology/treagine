local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local mathutils = require "treagine.util.mathutils"

local RenderSystem = tiny.sortedProcessingSystem(class("RenderSystem"))

function RenderSystem:init(screen)
	self.filter = tiny.requireAny("color",
								  tiny.requireAll("position", "size",
								  				  tiny.requireAny("image", "currentAnimation")))

	self.screen = screen
end

function RenderSystem:preProcess(dt)
	love.graphics.setCanvas(self.screen.canvas)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha")

	self.screen.camera:attach()
end

function RenderSystem:process(e, dt)
	love.graphics.setColor(e.color or 255, 255, 255, 255)
	if e.currentAnimation then
		e.currentAnimation:update(dt)
		e.currentAnimation:draw(e.image, mathutils.round(e.position.x), mathutils.round(e.position.y))
	else
		love.graphics.draw(e.image, mathutils.round(e.position.x), mathutils.round(e.position.y))
	end
end

function RenderSystem:postProcess(dt)
	self.screen.camera:detach()

	love.graphics.setCanvas()
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.screen.canvas, self.screen.viewport.position.x, self.screen.viewport.position.y, 0,
		self.screen.viewport.size.x / self.screen.canvas:getWidth(), self.screen.viewport.size.y / self.screen.canvas:getHeight())
end

function RenderSystem:compare(e1, e2)
	e1z = e1.zPos or 0
	e2z = e2.zPos or 0

	return e1z < e2z
end

return RenderSystem