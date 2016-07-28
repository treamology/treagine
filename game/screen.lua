local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local Camera = require "treagine.lib.camera"

local RenderSystem = require "treagine.system.rendersystem"
local FillViewport = require "treagine.render.fillviewport"
local rsettings = require "treagine.render.rendersettings"

local Screen = class("Screen")

function Screen:init(systems, canvas, viewport, camera)
	self.backgroundColor = {0, 0, 0, 0}
	self.systems = systems or {}

	self:setViewport(viewport or FillViewport())

	self.canvas = canvas or love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	self.camera = camera or Camera.new(self.canvas:getWidth(), self.canvas:getHeight())

	self.viewport.camera = self.camera

	self.started = false
end

function Screen:load()
	self.world = tiny.world()

	for _, v in ipairs(self.systems) do
		self.world:addSystem(v(self))
	end

	self.world:addSystem(RenderSystem(self))
end

function Screen:start()
	tiny.refresh(self.world)
	self.started = true
end

function Screen:update()
	love.graphics.setBackgroundColor(self.backgroundColor)
	tiny.update(self.world, love.timer.getDelta() * rsettings.timeScale)
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
	for _, system in pairs(self.world.systemsToAdd) do
		if system.name == name then
			return system
		end
	end
end

function Screen:setViewport(viewport)
	self.viewport = viewport
	self.viewport:recalculate()
end

return Screen