local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local Camera = require "treagine.lib.camera"

local RenderSystem = require "treagine.system.rendersystem"
local UpdateSystem = require "treagine.system.updatesystem"
local CanvasDrawSystem = require "treagine.system.canvasdrawsystem"

local FillViewport = require "treagine.render.fillviewport"
local gameconfig = require "treagine.config.gameconfig"

local Screen = class("Screen")

local probe
if gameconfig.profileMode then
	probe = require "treagine.lib.probe"
end

function Screen:init(systems, canvas, viewport, camera)
	self.backgroundColor = {0, 0, 0, 0}
	self.systems = systems or {}

	self:setViewport(viewport or FillViewport())

	self.canvas = canvas or love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	self.canvasWidth, self.canvasHeight = self.canvas:getWidth(), self.canvas:getHeight()
	self.camera = camera or Camera.new(self.canvasWidth, self.canvasHeight)

	self.viewport.camera = self.camera

	self.started = false
	self.paused = false

	if gameconfig.profileMode then
		self.dProbe = probe.new(60)
		self.uProbe = probe.new(60)
	end
end

function Screen:load()
	self.world = tiny.world()

	for _, v in ipairs(self.systems) do
		self.world:addSystem(v(self))
	end

	if gameconfig.profileMode then
		self.world:refresh()
		self.uProbe:hookAll(self.world.systems, "process", {self.world})
		self.uProbe:hookAll(self.world.systems, "update", {self.world})
		self.uProbe:hookAll(self.world.systems, "preProcess", {self.world})
		self.uProbe:hookAll(self.world.systems, "postProcess", {self.world})

		self.uProbe:enable(true)
	end

	self.world:addSystem(UpdateSystem(self))
	self.world:addSystem(CanvasDrawSystem(self))

	local rs = RenderSystem(self)
	self.world:addSystem(rs)

	if gameconfig.profileMode then
		self.dProbe:hook(rs, "drawRenderable", rs.name)
		self.dProbe:hook(rs, "process", rs.name)
		self.dProbe:hook(rs, "postProcess", rs.name)
		self.dProbe:hook(rs, "preProcess", rs.name)
		self.dProbe:enable(true)
	end

	self.world:refresh()
	for i = 1, #self.world.systems do
		local system = self.world.systems[i]
		system:awake()
	end
	--collectgarbage("stop")
end

function Screen:unload()
	for _, system in ipairs(self.world.systems) do
		self.world:removeSystem(system)
	end
	self.world:refresh()
	self.world = nil

	if gameconfig.profileMode then
		self.dProbe:enable(false)
		self.dProbe = nil
		self.uProbe:enable(false)
		self.uProbe = nil
	end
end

function Screen:start()
	self.world:refresh()
	for i = 1, #self.world.systems do
		local system = self.world.systems[i]
		system:start()
	end
	self.started = true
end

function Screen:update(dt)
	if gameconfig.profileMode then
		self.uProbe:startCycle()
	end
	if self.paused then
		tiny.update(self.world, dt * gameconfig.render.timeScale, tiny.requireAll("runWhenPaused", tiny.rejectAll("drawsToScreen")))
	else
		tiny.update(self.world, dt * gameconfig.render.timeScale, tiny.rejectAll("drawsToScreen"))
	end
	if gameconfig.profileMode then
		self.uProbe:endCycle()
	end
	--print(collectgarbage("count"))
end

function Screen:draw()
	if gameconfig.profileMode then
		self.dProbe:startCycle()
	end
	love.graphics.setBackgroundColor(self.backgroundColor)
	tiny.update(self.world, love.timer.getDelta() * gameconfig.render.timeScale, tiny.requireAll("drawsToScreen"))
	if gameconfig.profileMode then
		self.dProbe:endCycle()

		love.graphics.setColor(255, 255, 255)
		love.graphics.setCanvas()
		local ps = love.window.getPixelScale()
		self.dProbe:draw(20, 20, 150 * ps, 560 * ps, "Draw Cycle")
		self.uProbe:draw(630, 20, 150 * ps, 560 * ps, "Update Cycle")
	end
end

function Screen:resize(w, h)
	self.viewport:recalculate()
end

function Screen:getSystemByName(name)
	for _, system in pairs(self.world.systems) do
		if system.name == name then
			return system
		end
	end
	-- for _, system in pairs(self.world.systemsToAdd) do
	-- 	if system.name == name then
	-- 		return system
	-- 	end
	-- end
end

function Screen:isEntityInsideView(e)
	return e.position.x < self.viewport.camera.x + self.canvasWidth / 2 and
	       e.position.x > self.viewport.camera.x - self.canvasWidth / 2 and
	       e.position.y < self.viewport.camera.y + self.canvasHeight / 2 and
	       e.position.y > self.viewport.camera.y - self.canvasHeight / 2
end

function Screen:setViewport(viewport)
	self.viewport = viewport
	self.viewport:recalculate()
end

return Screen