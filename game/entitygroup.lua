local class = require "treagine.lib.30log"

local Entity = require "treagine.game.entity"

local EntityGroup = Entity:extend("EntityGroup")

function EntityGroup:init()
	EntityGroup.super.init(self)
	
	self.children = {}
end

return EntityGroup