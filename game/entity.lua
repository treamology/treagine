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
	self.position.x = x - (size.x / 2 - (self.anchor.x * size.x))
	self.position.y = y - (size.y / 2 - (self.anchor.y * size.y))
end

function Entity:getSize(factorScale)
	if factorScale == nil then factorScale = true end

	if self.size then
		if factorScale then
			return self.size * self.scale
		else
			return self.size
		end
	elseif self.image then
		local sizeX, sizeY = self.image:getDimensions()
		if factorScale then
			return vector(sizeX * self.scale.x, sizeY * self.scale.y)
		else
			return vector(sizeX, sizeYs)
		end
	end

	print(self.name .. " size was not returned.")
end

function Entity:getBoundingBox()
	local size = self:getSize()

	if self.boundingBox then
		return self.position.x + self.boundingBox.x - (self.anchor.x * size.x), self.position.y + self.boundingBox.y - (self.anchor.y * size.y), self.boundingBox.width * self.scale.x, self.boundingBox.height * self.scale.y
	end

	return self.position.x - (self.anchor.x * size.x), self.position.y - (self.anchor.y * size.y), size:unpack()
end

return Entity