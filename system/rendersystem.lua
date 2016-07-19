local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local vector = require "treagine.lib.vector"
local mathutils = require "treagine.util.mathutils"

local RenderSystem = tiny.sortedProcessingSystem(class("RenderSystem"))

function RenderSystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAll("position", "renderables")

	self.defaultShader = love.graphics.getShader()
end

function RenderSystem:drawRenderable(e, r, dt)
	love.graphics.setColor(r.color or 255, 255, 255, 255)

	-- valid types are "image", "canvas", "particleSystem", and "rect"
	assert(r.type, "Renderable must have a type.")

	-- shaders can be applied entity-wide, while also having renderable-specific shaders.
	-- renderable shaders override the shader applied to the entity, if any.
	if r.shader then
		if r.shaderExterns then
			for k, v in pairs(r.shaderExterns) do
				r.shader:send(k, v)
			end
		end

		love.graphics.setShader(r.shader)
	elseif e.shader then
		-- overwrite entity-wide externs with renderable specific
		local shaderExterns = e.shaderExterns or {}
		if r.shaderExterns then
			for k, v in pairs(r.shaderExterns) do
				shaderExterns[k] = v
			end
		end

		for k, v in pairs(shaderExterns) do
			e.shader:send(k, v)
		end

		love.graphics.setShader(e.shader)
	else
		love.graphics.setShader()
	end

	local offset = r.offset or vector(0, 0)
	local rotation = r.rotation or 0
	local scale = r.scale or vector(1, 1)

	local drawParams = { mathutils.round(e.position.x), mathutils.round(e.position.y), rotation, scale.x, scale.y, offset.x, offset.y }

	if r.type == "image" then
		if r.currentAnimation then
			r.currentAnimation:update(dt)
			r.currentAnimation:draw(r.image, unpack(drawParams))
		else
			love.graphics.draw(r.image, unpack(drawParams))
		end

	elseif r.type == "canvas" then
		love.graphics.draw(r.canvas, unpack(drawParams))

	elseif r.type == "particleSystem" then
		r.particleSystem:update(dt)
		love.graphics.draw(r.particleSystem, unpack(drawParams))

	elseif r.type == "rect" then
		local drawMode = r.drawMode or "fill"
		local size = r.size or vector(0, 0)

		love.graphics.rectangle(drawMode, mathutils.round(e.position.x + offset.x), mathutils.round(e.position.y + offset.y), size.x, size.y)
	end
end

function RenderSystem:preProcess(dt)
	love.graphics.setCanvas(self.screen.canvas)
	love.graphics.clear()

	self.screen.camera:attach()
end

function RenderSystem:process(e, dt)
	for _, r in pairs(e.renderables) do
		self:drawRenderable(e, r, dt)
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