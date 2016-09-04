local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local vector = require "treagine.lib.vector"
local mathutils = require "treagine.util.mathutils"

local RenderSystem = tiny.sortedProcessingSystem(class("RenderSystem"))

local function sortThenRender(self, e, dt, pixelScale)
	local orderedList = {}
	for _, v in pairs(e.renderList) do
		table.insert(orderedList, v)
	end
	table.sort(orderedList, function(a, b) return self:compare(a, b) end)

	for _, r in ipairs(orderedList) do
		self:drawRenderable(e, r, dt, pixelScale)
	end
end

function RenderSystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAll("position", "renderList")
	self.runWhenPaused = true

	self.offCanvasRenders = {}

	self.defaultShader = love.graphics.getShader()
end

function RenderSystem:onAdd(e)
	for _, r in pairs(e.renderList) do
		if not r.scale then r.scale = vector(1, 1) end
		if not r.offset then r.offset = vector(0, 0) end
		if not r.anchor then r.anchor = vector(0, 0) end
		if not r.rotation then r.rotation = 0 end
	end
end

function RenderSystem:drawRenderable(e, r, dt, pixelScale)
	if r.hidden then
		return
	end

	local pixelScale = pixelScale or 1

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

	local eScale = e.scale or vector(1, 1)
	local eScaleX, eScaleY = eScale.x, eScale.y
	local scaleX, scaleY = r.scale.x, r.scale.y
	local offsetX, offsetY = r.offset.x, r.offset.y
	local anchorX, anchorY = r.anchor.x, r.anchor.y
	local rotation = r.rotation

	local eScaleX, eScaleY = eScaleX * pixelScale, eScaleY * pixelScale
	--local scaleX, scaleY = scaleX * pixelScale, scaleY * pixelScale
	local offsetX, offsetY = offsetX * eScaleX, offsetY * eScaleY

	if r.currentAnimation then
		local sizeX, sizeY = r.currentAnimation:getDimensions()
		anchorX, anchorY = sizeX * anchorX, sizeY * anchorY

		local playAnim = r.currentAnimation.playWhenPaused
		if playAnim == nil then playAnim = true end

		if not self.screen.paused or playAnim then r.currentAnimation:update(dt) end
		r.currentAnimation:draw(r.image, mathutils.round(e.position.x + offsetX), mathutils.round(e.position.y + offsetY), rotation, scaleX, scaleY, anchorX, anchorY)
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
	
	elseif r.font and r.text then
		anchorX, anchorY = (r.font:getWidth(r.text)) * anchorX, r.font:getHeight() * anchorY
		if love.graphics.getFont() ~= r.font then
			love.graphics.setFont(r.font)
		end
		love.graphics.print(r.text, e.position.x + offsetX, e.position.y + offsetY, rotation, scaleX * eScaleX, scaleY * eScaleY, anchorX, anchorY)
		return
		
	end

	love.graphics.draw(r.image or r.canvas or r.particleSystem, mathutils.round(e.position.x + offsetX), mathutils.round(e.position.y + offsetY), rotation, scaleX * eScaleX, scaleY * eScaleY, mathutils.round(anchorX), mathutils.round(anchorY))
end

function RenderSystem:preProcess(dt)
	love.graphics.setCanvas(self.screen.canvas)
	love.graphics.clear()

	self.screen.camera:attach()
end

function RenderSystem:process(e, dt)
	if e.hidden then
		return
	end
	if e.renderOnScreen then
		table.insert(self.offCanvasRenders, e)
		return
	end

	sortThenRender(self, e, dt)
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

	for _, e in ipairs(self.offCanvasRenders) do
		sortThenRender(self, e, dt, love.window.getPixelScale())
	end

	for k in ipairs(self.offCanvasRenders) do
		self.offCanvasRenders[k] = nil
	end
end

function RenderSystem:compare(e1, e2)
	e1z = e1.zPos or 0
	e2z = e2.zPos or 0

	return e1z < e2z
end

return RenderSystem