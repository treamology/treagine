local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local rsettings = require "treagine.render.rendersettings"
local vector = require "treagine.lib.vector"

local DebugDrawSystem = class("DebugDrawSystem")

function DebugDrawSystem:init(screen)
	self.rectList = {}
	self.drawFPS = false
	self.showEntityBounds = false
	self.showEntityAnchors = false

	self.screen = screen

	beholder.observe("debug", "drawRectangle", function(table) self:addRectangle(table) end)
	beholder.observe("debug", "showEntityBounds", function(bool) self.showEntityBounds = bool end)
	beholder.observe("debug", "showEntityAnchors", function(bool) self.showEntityAnchors = bool end)
end

function DebugDrawSystem:draw()
	love.graphics.setBlendMode("alpha")

	if self.drawFPS then
		local r, g, b, a = love.graphics.getBackgroundColor()
		love.graphics.setColor(255 - r, 255 - g, 255 - b, 255)
		love.graphics.setDefaultFont()
		love.graphics.print(tostring(love.timer.getFPS()) .. " fps", 0, 0)
	end

	if self.showEntityBounds then
		local color = {255, 0, 255, 255}
		local mode = "line"

		love.graphics.setColor(color)
		for e in pairs(self.screen.world.entities) do
			if not e.renderOnScreen then
				local x, y, w, h = e:getBoundingBox()
				local px, py = self.screen.viewport:project(vector(x, y)):unpack()
				w = w * rsettings.scaleFactor * self.screen.viewport.scale
				h = h * rsettings.scaleFactor * self.screen.viewport.scale
				love.graphics.rectangle(mode, px, py, w, h)
			end
		end
	end

	if self.showEntityAnchors then
		local color = {255, 0, 0, 255}
		local mode = "fill"

		love.graphics.setColor(color)
		for e in pairs(self.screen.world.entities) do
			if not e.renderOnScreen then
				local x = e.position.x
				local y = e.position.y
				local px, py = self.screen.viewport:project(vector(x, y)):unpack()

				love.graphics.circle(mode, px, py, 2, 4)
			end
		end
	end

	if self.showCalculatedCenters then
		local color = {0, 255, 0, 255}
		local mode = "fill"

		love.graphics.setColor(color)
		for e in pairs(self.screen.world.entities) do
			if not e.renderOnScreen then
				local x, y = e:getCenter()
				local px, py = self.screen.viewport:project(vector(x, y)):unpack()

				love.graphics.circle(mode, px, py, 2, 4)
			end
		end
	end
	
	for k, v in pairs(self.rectList) do
		if v.size ~= nil and v.position ~= nil then
			local color = v.color or {255, 0, 0, 255}
			local mode = v.mode or "line"
			local pos = v.position:clone() or vector(0, 0)
			local projPosX, projPosY = self.screen.viewport:project(pos):unpack()
			v.size = v.size * rsettings.scaleFactor * self.screen.viewport.scale

			love.graphics.setColor(color)
			love.graphics.rectangle(mode, projPosX, projPosY, v.size:unpack())
		else
			print("warning: position and size must be provided for debug rectangle")
		end
	end

	for k, v in pairs(self.rectList) do
		self.rectList[k] = nil
	end
end

function DebugDrawSystem:addRectangle(rect)
	table.insert(self.rectList, rect)
end

return DebugDrawSystem