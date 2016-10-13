local tiny = require "treagine.lib.tiny"
local class = require "treagine.lib.30log"
local beholder = require "treagine.lib.beholder"
local vector = require "treagine.lib.vector"

local System = class("System")

function System:init(screen)
	self.screen = screen
end

function System:awake()
	
end

function System:start()

end

return System