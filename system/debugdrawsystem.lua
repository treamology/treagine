local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"

local DebugDrawSystem = class("DebugDrawSystem")

function DebugDrawSystem:init()
	self.rectList = {}
	self.drawFPS = false

	beholder.observe("debug", "drawRectangle", function(table) self:addRectangle(table) end)
end

function DebugDrawSystem:draw()
	love.graphics.setBlendMode("alpha")

	if self.drawFPS then
		local r, g, b, a = love.graphics.getBackgroundColor()
		love.graphics.setColor(255 - r, 255 - g, 255 - b, 255)
		love.graphics.print(tostring(love.timer.getFPS()) .. " fps", 0, 0)
	end
	
	for k, v in pairs(self.rectList) do
		if v.size ~= nil and v.position ~= nil then
			local color = v.color or {255, 0, 255, 255}
			local mode = v.mode or "line"
			local pos = v.position:clone() or vector(0, 0)
			local projPosX, projPosY = mainViewport:project(pos):unpack()
			v.size = v.size * SCALE_FACTOR * mainViewport.scale

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