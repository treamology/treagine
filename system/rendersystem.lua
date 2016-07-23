local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local vector = require "treagine.lib.vector"
local mathutils = require "treagine.util.mathutils"

local RenderSystem = tiny.sortedProcessingSystem(class("RenderSystem"))

function RenderSystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAll("position", "renderList")

	self.defaultShader = love.graphics.getShader()
end

function RenderSystem:drawRenderable(e, r, dt)
	love.graphics.setColor(r.color or e.color or 255, 255, 255, 255)

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

	local offsetX, offsetY, anchorX, anchorY, rotation, scaleX, scaleY

	if r.offset then offsetX, offsetY = r.offset.x, r.offset.y else offsetX, offsetY = 0, 0 end
	if r.rotation then rotation = r.rotation else rotation = 0 end
	if r.scale then scaleX, scaleY = r.scale.x, r.scale.y else scaleX, scaleY = 1, 1 end
	if r.anchor then anchorX, anchorY = r.anchor.x, r.anchor.y else anchorX, anchorY = 0, 0 end

	if r.currentAnimation then
		local sizeX, sizeY = r.currentAnimation:getDimensions()
		anchorX, anchorY = sizeX * anchorX, sizeY * anchorY

		r.currentAnimation:update(dt)
		r.currentAnimation:draw(r.image, mathutils.round(e.position.x) + offsetX, mathutils.round(e.position.y) + offsetY, rotation, scaleX, scaleY, anchorX, anchorY)
		return

	elseif r.image then
		local sizeX, sizeY = r.image:getDimensions()
		anchorX, anchorY = sizeX * anchorX, sizeY * anchorY

	elseif r.particleSystem then
		r.particleSystem:update(dt)

	elseif r.drawMode then
		anchorX, anchorY = r.size.x * -anchorX, r.size.y * -anchorY
		love.graphics.rectangle(r.drawMode, mathutils.round(e.position.x + offsetX + anchorX), mathutils.round(e.position.y + offsetY + anchorY), r.size.x, r.size.y)
		return
	end

	love.graphics.draw(r.image or r.canvas or r.particleSystem, mathutils.round(e.position.x) + offsetX, mathutils.round(e.position.y) + offsetY, rotation, scaleX, scaleY, anchorX, anchorY)
end

function RenderSystem:preProcess(dt)
	love.graphics.setCanvas(self.screen.canvas)
	love.graphics.clear()

	self.screen.camera:attach()
end

function RenderSystem:process(e, dt)
	local orderedList = {}
	for _, v in pairs(e.renderList) do
		table.insert(orderedList, v)
	end
	table.sort(orderedList, function(a, b) return self:compare(a, b) end)

	for _, r in ipairs(orderedList) do
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