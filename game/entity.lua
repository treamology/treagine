local class = require "treagine.lib.30log"
local vector = require "treagine.lib.vector"

local Entity = class("Entity")

function Entity:init()
	self.position = vector(0, 0)
	self.scale = vector(1, 1)
	self.rotation = 0 -- in radians
	self.anchor = vector(0, 0)
end

function Entity:getCenter()
	return self.position + (self.size / 2)
end

function Entity:setCenter(x, y)
	self.position.x = x - (self.size.x / 2)
	self.position.y = y - (self.size.y / 2)
end

return Entity