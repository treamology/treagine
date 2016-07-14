local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local Camera = require "treagine.lib.camera"

local RenderSystem = require "treagine.system.rendersystem"
local rsettings = require "treagine.render.rendersettings"

local Screen = class("Screen")

function Screen:init(systems, canvas, viewport, camera)
	self.backgroundColor = {0, 0, 0, 0}
	self.systems = systems or {}

	self.viewport = viewport

	self.canvas = canvas or love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
	self.camera = camera or Camera.new(self.canvas:getWidth(), self.canvas:getHeight())

	self.viewport.camera = self.camera
end

function Screen:load()
	self.world = tiny.world()

	for _, v in ipairs(self.systems) do
		self.world:addSystem(v(self))
	end

	self.world:addSystem(RenderSystem(self))
end

function Screen:update()
	love.graphics.setBackgroundColor(self.backgroundColor)
	tiny.update(self.world, love.timer.getDelta() * rsettings.timeScale)
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

return Screen