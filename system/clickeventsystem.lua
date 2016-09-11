local tiny = require "treagine.lib.tiny"
local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local vector = require "treagine.lib.vector"

local InputEventProcessor = require "treagine.input.inputeventprocessor"

local MouseProcessor = require "treagine.input.mouseprocessor"

local ClickEventSystem = tiny.system(class("ClickEventSystem"))

local UI_PRESSED = "UI_PRESSED"
local UI_RELEASED = "UI_RELEASED"
local UI_HOVERED = "UI_HOVERED"

function ClickEventSystem:init(screen)
	self.screen = screen

	self.runWhenPaused = true

	self.pressedEntity = nil

	self.mousePressedEvent = beholder.observe(MouseProcessor.MOUSE_PRESSED, 1, function(istouch, x, y) self:mousePressed(istouch, x, y) end)
	self.mouseReleasedEvent = beholder.observe(MouseProcessor.MOUSE_RELEASED, 1, function(istouch, x, y) self:mouseReleased(istouch, x, y) end)
end

function ClickEventSystem:onRemoveFromWorld(world)
	beholder.stopObserving(self.mousePressedEvent)
	beholder.stopObserving(self.mouseReleasedEvent)
end

function ClickEventSystem:mousePressed(istouch, x, y)
	local hit = self:hitTest(x, y)

	if hit then
		beholder.trigger(UI_PRESSED, hit)
		self.pressedEntity = hit
	end
end

function ClickEventSystem:mouseReleased(istouch, x, y)
	local hit = self:hitTest(x, y)

	if hit and self.pressedEntity == hit then
		beholder.trigger(UI_RELEASED, hit)
	end
	self.pressedEntity = nil
end

function ClickEventSystem:update(dt)
	local hit = self:hitTest(love.mouse.getPosition())

	if hit then
		beholder.trigger(UI_HOVERED, hit)
	else
		InputEventProcessor.mouseUpdate()
	end
end

function ClickEventSystem:hitTest(x, y)
	if self.world == nil then return end
	local hitEntity

	for k, v in pairs(self.entities) do
		local unprojPos = self.screen.viewport:unproject(vector(x, y))
		local bx, by, bw, bh = v:getBoundingBox()
		if unprojPos.x > bx and unprojPos.x < bx + bw and unprojPos.y > by and unprojPos.y < by + bh then
			if hitEntity == nil or hitEntity.zPos < v.zPos then
				hitEntity = v
			end
		end
	end

	return hitEntity
end

function ClickEventSystem:filter(e)
	return e.interceptsMouse
end

return ClickEventSystem