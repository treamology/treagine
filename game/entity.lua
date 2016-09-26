--- Base class for anything that belongs in the world and has systems operating on it.
-- @classmod Entity
-- @alias self

local class = require "treagine.lib.30log"
local vector = require "treagine.lib.vector"
local vectorl = require "treagine.lib.vector-light"

local Entity = class("Entity")

function Entity:init()
	--- (**vector**) Position of the entity.
	self.position = vector(0, 0)
	--- List of objects on the entity to render.
	self.renderList = {}
end

--- Calculates and returns the center of the entity based on what's in Entity.renderList
-- @treturn number x position of the center of the entity.
-- @treturn number y position of the center of the entity.
function Entity:getCenter()
	local bx, by, bw, bh = self:getTrueBounds()
	local x, y = self.position.x + bx + bw / 2, self.position.y + by + bh / 2
	return x, y
end

--- Calculates the bounds of the entity based on what is being rendered.
-- @treturn number x position relative to the position of the entity.
-- @treturn number y position relative to the position of the entity.
-- @treturn number Width of the bounding box.
-- @treturn number Height of the bounding box.
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

--- Returns only the width and height from the calculated bounding box.
-- @see getTrueBounds
-- @treturn number width of the entity
-- @treturn number height of the entity
function Entity:getSize()
	local _, _, width, height = self:getTrueBounds()
	return width, height
end

--- Returns either the calculated bounding box or the user-defined one.
-- @see getTrueBounds
-- @treturn number x
-- @treturn number y
-- @treturn number width
-- @treturn number height
function Entity:getBoundingBox()
	if self.boundingBox then
		return self.position.x + self.boundingBox.x, self.position.y + self.boundingBox.y, self.boundingBox.width, self.boundingBox.height
	end
	local x, y, w, h = self:getTrueBounds()
	return self.position.x + x, self.position.y + y, w, h

end

return Entity