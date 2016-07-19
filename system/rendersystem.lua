local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local mathutils = require "treagine.util.mathutils"

local RenderSystem = tiny.sortedProcessingSystem(class("RenderSystem"))

function RenderSystem:init(screen)
	self.filter = tiny.requireAll("position", "scale", "rotation", "anchor",
								  tiny.requireAny("image",
												  tiny.requireAll("drawMode", "size"),
												  "text",
												  "children",
												  "canvas",
												  "particleSystem"))

	self.screen = screen
	self.uiSystem = screen:getSystemByName("UISystem")
end

function RenderSystem:drawEntity(e, position, dt)
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

	local anchorX, anchorY = 0, 0

	local size = e:getSize(false)
	if size then
		anchorX, anchorY = e.anchor:unpack()

		anchorX = anchorX * size.x
		anchorY = anchorY * size.y
	end

	if e.image then
		if e.currentAnimation then
			e.currentAnimation:update(dt)
			e.currentAnimation:draw(e.image, mathutils.round(position.x), mathutils.round(position.y), e.rotation, e.scale.x, e.scale.y, anchorX, anchorY)
		else
			love.graphics.draw(e.image, mathutils.round(position.x), mathutils.round(position.y), e.rotation, e.scale.x, e.scale.y, anchorX, anchorY)
		end
	elseif e.canvas then
		--dunno if we need this, turn it back on if there's a bug with it.
		--love.graphics.setBlendMode("alpha", "premultiplied")
		love.graphics.draw(e.canvas, mathutils.round(position.x), mathutils.round(position.y), e.rotation, e.scale.x, e.scale.y, anchorX, anchorY)
		--love.graphics.setBlendMode("alpha")
	elseif e.particleSystem then
		e.particleSystem:update(dt)
		love.graphics.draw(e.particleSystem, mathutils.round(position.x), mathutils.round(position.y), e.rotation, e.scale.x, e.scale.y, anchorX, anchorY)
	elseif e.drawMode then
		love.graphics.rectangle(e.drawMode, position.x, position.y, e.size.x, e.size.y)
	elseif e.text then
		if e.font then
			love.graphics.setFont(e.font)
		else
			love.graphics.setNewFont(12)
		end
		love.graphics.print(e.text, position.x, position.y, e.rotation, e.scale.x, e.scale.y, anchorX, anchorY)
	end
end

function RenderSystem:preProcess(dt)
	love.graphics.setCanvas(self.screen.canvas)
	love.graphics.clear()

	self.screen.camera:attach()
end

function RenderSystem:process(e, dt)
	end
end

function RenderSystem:postProcess(dt)
	self.screen.camera:detach()

	love.graphics.setCanvas()
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setShader()
	love.graphics.draw(self.screen.canvas, self.screen.viewport.position.x, self.screen.viewport.position.y, 0,
		self.screen.viewport.size.x / self.screen.canvas:getWidth(), self.screen.viewport.size.y / self.screen.canvas:getHeight())
	love.graphics.setBlendMode("alpha")
end

function RenderSystem:compare(e1, e2)
	e1z = e1.zPos or 0
	e2z = e2.zPos or 0

	return e1z < e2z
end

return RenderSystem