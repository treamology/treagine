local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local vector = require "treagine.lib.vector"
local tiny = require "treagine.lib.tiny"

local System = require "treagine.system.system"

local UpdateSystem = tiny.processingSystem(System:extend("UpdateSystem"))

function UpdateSystem:init(screen)
	self.screen = screen

	self.filter = tiny.requireAll("update")
end

function UpdateSystem:process(e, dt)
	e:update(dt, self.screen)
end

return UpdateSystem