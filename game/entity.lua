local class = require "treagine.lib.30log"
local vector = require "treagine.lib.vector"
local vectorl = require "treagine.lib.vector-light"

local Entity = class("Entity")

function Entity:init()
	self.position = vector(0, 0)
	self.renderables = {}
end

function Entity:getCenter()
	return self.position + self:getSize() / 2
end

function Entity:setCenter(x, y)
	local size = self:getSize()
	self.position.x = x - (size.x / 2)
	self.position.y = y - (size.y / 2)
end

function Entity:getTrueBounds()
	local minX, minY, maxX, maxY = 0, 0, 0, 0

	for _, r in ipairs(self.renderables) do
		local offset = -(r.offset or vector(0, 0))
		local size = r.size or vector(r.image:getDimensions()) or vector(0, 0)
		if offset.x < minX then minX = offset.x end
		if offset.y < minY then minY = offset.y end
		if offset.x + size.x > maxX then maxX = offset.x + size.x end
		if offset.y + size.y > maxY then maxY = offset.y + size.y end
	end

	local x = minX
	local y = minY
	local width = vectorl.dist(maxX, minY, minX, minY)
	local height = vectorl.dist(minX, minY, minX, maxY)

	return x, y, width, height
end

function Entity:getSize()
	local _, _, width, height = self:getTrueBounds()
	return width, height
end

function Entity:getBoundingBox()
	if self.boundingBox then
		return self.position.x + self.boundingBox.x, self.position.y + self.boundingBox.y, self.boundingBox.width, self.boundingBox.height
	end
	local x, y, w, h = self:getTrueBounds()
	return self.position.x + x, self.position.y + y, w, h

end

return Entity