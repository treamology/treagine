local Entity = class("Entity")

function Entity:init()
	self.position = vector(0, 0)
	self.size = vector(0, 0)
end

function Entity:getCenter()
	return self.position + (self.size / 2)
end

function Entity:setCenter(x, y)
	self.position.x = x - (self.size.x / 2)
	self.position.y = y - (self.size.y / 2)
end

return Entity