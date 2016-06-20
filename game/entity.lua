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
	if self.image then
		local sizeX = self.image:getWidth() * self.scale.x
		local sizeY = self.image:getHeight() * self.scale.y
		return self.position + (vector(sizeX, sizeY) / 2)
	elseif self.size then
		return self.position + (self.size / 2)
	end
	return self.position
end

function Entity:setCenter(x, y)
	if self.image then
		local sizeX = self.image:getWidth() * self.scale.x
		local sizeY = self.image:getHeight() * self.scale.y
		self.position.x = x - (sizeX / 2)
		self.position.y = y - (sizeY / 2)
		return
	elseif self.size then
		self.position.x = x - (self.size.x / 2)
		self.position.y = y - (self.size.y / 2)
		return
	end
	
	self.position.x = x
	self.position.y = y
end

return Entity