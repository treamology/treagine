local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"

local ShapeSystem = tiny.processingSystem(class("ShapeSystem"))

function ShapeSystem:init()
	self.filter = tiny.requireAll("position", "size", "drawMode", "color")
end

function ShapeSystem:process(e, dt)
	love.graphics.setColor(e.color.r, e.color.g, e.color.b, e.color.a)
	love.graphics.rectangle(e.drawMode, e.position.x, e.position.y, e.size.x, e.size.y)
end

return ShapeSystem