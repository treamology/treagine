local class = require "treagine.lib.30log"
local vector = require "treagine.lib.vector"
local vectorl = require "treagine.lib.vector-light"

local Entity = class("Entity")

function Entity:init()
	self.position = vector(0, 0)
	self.renderList = {}
end

function Entity:getCenter()
	local bx, by, bw, bh = self:getTrueBounds()
	local x, y = self.position.x + bx + bw / 2, self.position.y + by + bh / 2
	return x, y
end

function Entity:getTrueBounds()
	local minX, minY, maxX, maxY = 0, 0, 0, 0

	for _, r in pairs(self.renderList) do
		local offsetX, offsetY = 0, 0
		if r.offset then offsetX, offsetY = r.offset.x, r.offset.y end

		local animDimensions
		if r.currentAnimation then
			animDimensions = vector(r.currentAnimation:getDimensions())
		end

		local imageDimensions
		if r.image then
			imageDimensions = vector(r.image:getDimensions())
		end

		local fontDimensions
		if r.font and r.text then
			fontDimensions = vector(r.font:getWidth(r.text), r.font:getHeight())
		end

		local size = r.size or animDimensions or imageDimensions or fontDimensions or vector(0, 0)
		if r.scale then size = size * r.scale end

		local anchorX, anchorY = 0, 0
		if r.anchor then anchorX, anchorY = r.anchor.x, r.anchor.y end
		anchorX, anchorY = size.x * -anchorX, size.y * -anchorY

		if offsetX + anchorX < minX then minX = offsetX + anchorX end
		if offsetY + anchorY < minY then minY = offsetY + anchorY end
		if offsetX + anchorX + size.x > maxX then maxX = offsetX + anchorX + size.x end
		if offsetY + anchorY + size.y > maxY then maxY = offsetY + anchorY + size.y end
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