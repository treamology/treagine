local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local vector = require "treagine.lib.vector"
local tiny = require "treagine.lib.tiny"

local System = require "treagine.system.system"

local UpdateSystem = tiny.processingSystem(System:extend("UpdateSystem"))

function UpdateSystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAny("update", "onRemove", "onAdd")
end

function UpdateSystem:process(e, dt)
	if e.update then
		e:update(dt, self.screen)
	end
end

function UpdateSystem:onRemove(e)
	if e.onRemove then
		e:onRemove()
	end
end

function UpdateSystem:onAdd(e)
	if e.onAdd then
		e:onAdd()
	end
end

return UpdateSystem