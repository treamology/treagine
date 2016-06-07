local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local mathutils = require "treagine.util.mathutils"

local SpriteSystem = tiny.sortedProcessingSystem(class("SpriteSystem"))

function SpriteSystem:init()
	self.filter = tiny.requireAny("color",
								  tiny.requireAll("position", "size",
								  				  tiny.requireAny("image", "currentAnimation")))
end

function SpriteSystem:preProcess(dt)
	mainCamera:attach()
end

function SpriteSystem:process(e, dt)
	love.graphics.setColor(e.color or 255, 255, 255, 255)
	if e.currentAnimation then
		e.currentAnimation:update(dt)
		e.currentAnimation:draw(e.image, mathutils.round(e.position.x), mathutils.round(e.position.y))
	else
		love.graphics.draw(e.image, mathutils.round(e.position.x), mathutils.round(e.position.y))
	end
end

function SpriteSystem:postProcess(dt)
	mainCamera:detach()
end

function SpriteSystem:compare(e1, e2)
	e1z = e1.zPos or 0
	e2z = e2.zPos or 0

	return e1z < e2z
end

return SpriteSystem