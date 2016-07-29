local tiny = require "treagine.lib.tiny"
local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local vector = require "treagine.lib.vector"

local InputEventProcessor = require "treagine.input.inputeventprocessor"

local MouseProcessor = require "treagine.input.mouseprocessor"

local UISystem = tiny.system(class("UISystem"))

local UI_PRESSED = "UI_PRESSED"
local UI_RELEASED = "UI_RELEASED"
local UI_HOVERED = "UI_HOVERED"

function UISystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAll("interceptsMouse")
	self.runWhenPaused = true

	self.pressedEntity = nil

	beholder.observe(MouseProcessor.MOUSE_PRESSED, 1, function(istouch, x, y) self:mousePressed(istouch, x, y) end)
	beholder.observe(MouseProcessor.MOUSE_RELEASED, 1, function(istouch, x, y) self:mouseReleased(istouch, x, y) end)
end

function UISystem:mousePressed(istouch, x, y)
	local hit = self:hitTest(x, y)

	if hit then
		beholder.trigger(UI_PRESSED, hit)
		self.pressedEntity = hit
	end
end

function UISystem:mouseReleased(istouch, x, y)
	local hit = self:hitTest(x, y)

	if hit and self.pressedEntity == hit then
		beholder.trigger(UI_RELEASED, hit)
	end
	self.pressedEntity = nil
end

function UISystem:update(dt)
	local hit = self:hitTest(love.mouse.getPosition())

	if hit then
		beholder.trigger(UI_HOVERED, hit)
	else
		InputEventProcessor.mouseUpdate()
	end
end

function UISystem:hitTest(x, y)
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

return UISystem