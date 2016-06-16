local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local vector = require "treagine.lib.vector"

local UISystem = tiny.system(class("UISystem"))

local rootNode = { position = vector(0, 0), children = {} }

function UISystem(screen)
	self.screen = screen

	self.filter = tiny.requireAll("anchor", "parent", "position")
end

function UISystem:onAdd(e)
	e.children = {}

	table.insert(e.parent.children, e)
end

function UISystem:update(e)

end

function UISystem:onRemove(e)
	
end

UISystem.rootNode = rootNode

return UISystem