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
	return self.position + self:getSize() / 2
end

function Entity:setCenter(x, y)
	local size = self:getSize()
	self.position.x = x - (size.x / 2)
	self.position.y = y - (size.y / 2)
end

function Entity:getSize()
	if self.size then
		return self.size
	elseif self.image then
		local sizeX, sizeY = self.image:getDimensions()
		local size = vector(sizeX * self.scale.x, sizeY * self.scale.y)
		return size
	end

	print(self.name .. " size was not returned.")
end

return Entity