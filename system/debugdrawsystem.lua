local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local rsettings = require "treagine.render.rendersettings"
local vector = require "treagine.lib.vector"

local DebugDrawSystem = class("DebugDrawSystem")

function DebugDrawSystem:init(screen)
	self.rectList = {}
	self.lineList = {}
	self.pointList = {}
	self.drawFPS = false
	self.showEntityBounds = false
	self.showEntityAnchors = false

	self.screen = screen

	beholder.observe("debug", "drawRectangle", function(table) self:addRectangle(table) end)
	beholder.observe("debug", "drawLine", function(table) self:addLine(table) end)
	beholder.observe("debug", "drawPoint", function(table) self:addPoint(table) end)
	beholder.observe("debug", "showEntityBounds", function(bool) self.showEntityBounds = bool end)
	beholder.observe("debug", "showEntityAnchors", function(bool) self.showEntityAnchors = bool end)

	beholder.observe("SCREEN_SWITCHED", function(screen)
		self.screen = screen
	end)
end

function DebugDrawSystem:draw()
	if not self.screen.world then return end
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
			local projPosX, projPosY
			if v.screenSpace then
				projPosX, projPosY = pos:unpack()
			else
				v.size = v.size * rsettings.scaleFactor * self.screen.viewport.scale
				projPosX, projPosY = self.screen.viewport:project(pos):unpack()
			end

			love.graphics.setColor(color)
			love.graphics.rectangle(mode, projPosX, projPosY, v.size:unpack())
		else
			print("warning: position and size must be provided for debug rectangle")
		end
	end

	for k, v in pairs(self.lineList) do
		local color = v.color or {255, 0, 0, 255}
		local screenSpace = v.screenSpace or false

		local px1, py1, px2, py2
		if screenSpace then
			px1, py1, px2, py2 = v.x1, v.y1, v.x2, v.y2
		else
			px1, py1 = self.screen.viewport:projectLight(v.x1, v.y1)
			px2, py2 = self.screen.viewport:projectLight(v.x2, v.y2)
		end

		love.graphics.setColor(color)
		love.graphics.line(px1, py1, px2, py2)
	end

	for k, v in pairs(self.pointList) do
		local color = v.color or {255, 0, 0, 255}
		local screenSpace = v.screenSpace or false

		local px, py
		if screenSpace then
			px, py = v.x, v.y
		else
			px, py = self.screen.viewport:projectLight(v.x, v.y)
		end

		love.graphics.setColor(color)
		love.graphics.points(px, py)
	end

	for k, v in pairs(self.rectList) do
		self.rectList[k] = nil
	end
	for k, v in pairs(self.lineList) do
		self.lineList[k] = nil
	end
	for k, v in pairs(self.pointList) do
		self.pointList[k] = nil
	end
end

function DebugDrawSystem:addRectangle(rect)
	table.insert(self.rectList, rect)
end

function DebugDrawSystem:addLine(line)
	table.insert(self.lineList, line)
end

function DebugDrawSystem:addPoint(point)
	table.insert(self.pointList, point)
end

return DebugDrawSystem