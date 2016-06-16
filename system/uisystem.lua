local class = require "treagine.lib.30log"
local tiny = require "treagine.lib.tiny"
local vector = require "treagine.lib.vector"

local UISystem = tiny.system(class("UISystem"))

local rootNode = { absolutePosition = vector(0, 0), children = {} }

function UISystem(screen)
	self.screen = screen

	self.filter = tiny.requireAll("anchorPoint", "parent", "position", "size")
end

function UISystem:onAdd(e)
	table.insert(e.parent.children, e)

	e.children = {}
end

function UISystem:update(e)
	local function traverseNode(node)
		for _, child in ipairs(node.children) do
			local anchorOffsetX = node.size.x * node.anchorPoint.x
			local anchorOffsetY = node.size.y * node.anchorPoint.y

			local absX = node.absolutePosition.x + child.position.x + anchorOffsetX
			local absY = node.absolutePosition.y + child.position.y + anchorOffsetY

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

	traverseNode(rootNode)
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

UISystem.rootNode = rootNode

return UISystem