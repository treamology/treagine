local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local mathutils = require "treagine.util.mathutils"

local RenderSystem = tiny.sortedProcessingSystem(class("RenderSystem"))

function RenderSystem:init(screen)
	self.filter = tiny.requireAll("position", "size", tiny.requireAny("image", "drawMode", "text"))

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

	if e.image then
		local xSize, ySize = e.size:unpack()
		local xScale = xSize / e.image:getWidth()
		local yScale = ySize / e.image:getHeight()

		if e.currentAnimation then
			e.currentAnimation:update(dt)
			e.currentAnimation:draw(e.image, mathutils.round(position.x), mathutils.round(position.y))
		else
			love.graphics.draw(e.image, mathutils.round(position.x), mathutils.round(position.y), 0, xScale, yScale)
		end
	elseif e.drawMode then
		love.graphics.rectangle(e.drawMode, position.x, position.y, e.size:unpack())
	elseif e.text then
		if e.font then
			love.graphics.setFont(e.font)
		else
			love.graphics.setNewFont(12)
		end
		love.graphics.print(e.text, position.x, position.y)
	end
end

function RenderSystem:preProcess(dt)
	love.graphics.setCanvas(self.screen.canvas)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha")

	self.screen.camera:attach()
end

function RenderSystem:process(e, dt)
	-- UI gets rendered later
	if e.parent then return end

	self:drawEntity(e, e.position, dt)
end

function RenderSystem:postProcess(dt)
	self.screen.camera:detach()

	if self.uiSystem then
		for _, node in ipairs(self.uiSystem.entities) do
			self:drawEntity(node, node.absolutePosition, dt)
		end
	end

	love.graphics.setCanvas()
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setShader()
	love.graphics.draw(self.screen.canvas, self.screen.viewport.position.x, self.screen.viewport.position.y, 0,
		self.screen.viewport.size.x / self.screen.canvas:getWidth(), self.screen.viewport.size.y / self.screen.canvas:getHeight())
end

function RenderSystem:compare(e1, e2)
	e1z = e1.zPos or 0
	e2z = e2.zPos or 0

	return e1z < e2z
end

return RenderSystem