local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local vector = require "treagine.lib.vector"

local UISystem = tiny.system(class("UISystem"))

function UISystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAll("anchorPoint", "parent", "position", "size")

	self.rootNode = { absolutePosition = vector(0, 0), children = {} }
end

function UISystem:onAdd(e)
	table.insert(e.parent.children, e)

	e.children = {}
end

function UISystem:update(e)
	local function traverseNode(node)
		for _, child in ipairs(node.children) do
			local anchorOffsetX = child.size.x * child.anchorPoint.x
			local anchorOffsetY = child.size.y * child.anchorPoint.y

			local absX = node.absolutePosition.x + child.position.x - anchorOffsetX
			local absY = node.absolutePosition.y + child.position.y - anchorOffsetY

			if child.absolutePosition ~= nil then
				child.absolutePosition.x = absX
				child.absolutePosition.y = absY
			else
				child.absolutePosition = vector(absX, absY)
			end

			if #child.children > 0 then
				traverseNode(child)
			end
		end
	end

	traverseNode(self.rootNode)
end

function UISystem:onRemove(e)
	for index, node in ipairs(e.parent.children) do
		if node == e then
			table.remove(e.parent, index)
			for _, child in ipairs(e.children) do
				self.world:removeEntity(child)
			end
		end
	end
end

return UISystem