local class = require "treagine.lib.30log"

local GameManager = class("GameManager")

function GameManager:init()
	self.currentScreen = nil
end

function GameManager:load()

end

function GameManager:update(dt)
	self.currentScreen.update(dt)
end

return GameManager