local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local mathutils = require "treagine.util.mathutils"

local RenderSystem = tiny.sortedProcessingSystem(class("RenderSystem"))

function RenderSystem:init(screen)
	self.filter = tiny.requireAll("position", "size", tiny.requireAny("image", "drawMode"))

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
	
	if e.shader then
		if e.shaderExterns then
			for k, v in pairs(e.shaderExterns) do
				e.shader:send(k, v)
			end
		end
		love.graphics.setShader(e.shader)
	else
		love.graphics.setShader()
	end

	if e.currentAnimation then
		e.currentAnimation:update(dt)
		e.currentAnimation:draw(e.image, mathutils.round(e.position.x), mathutils.round(e.position.y))
	elseif e.image then
		love.graphics.draw(e.image, mathutils.round(e.position.x), mathutils.round(e.position.y))
	else
		love.graphics.rectangle(e.drawMode, e.position.x, e.position.y, e.size:unpack())
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