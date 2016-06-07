local math = require "src.utils.mathutils"
local themes = require "src.graphics.themes"

local ThemeSystem = tiny.processingSystem(class("ThemeSystem"))

function ThemeSystem:init()
	self.filter = tiny.requireAll("color")

	self.currentTheme = themes.defaultTheme
	self.currentDestTheme = nil
	self.currentLerpTheme = self.currentTheme
	
	self.lerpTime = 0.5

	self.changingTheme = false
	self.lerpCounter = 0

	beholder.observe("changeTheme", function(destTheme) self:changeTheme(destTheme) end)
end

function ThemeSystem:changeTheme(destTheme)
	if self.currentTheme ~= destTheme and not self.changingTheme then
		self.lerpCounter = 0	
		self.changingTheme = true
		self.currentDestTheme = destTheme
	end
end

function ThemeSystem:onAdd(e)
	e.color = self.currentLerpTheme.fgColor
end

function ThemeSystem:process(e, dt)
	if self.changingTheme then
		if e.name == "Player" then
			e.baseColor = self.currentLerpTheme.fgColor
		else
			e.color = self.currentLerpTheme.fgColor
		end
	end
end

function ThemeSystem:preProcess(dt)
	if self.changingTheme then
		self.currentLerpTheme = themes.lerp(self.currentTheme, self.currentDestTheme, self.lerpCounter / self.lerpTime)

		currentScreen.backgroundColor = self.currentLerpTheme.bgColor

		if self.lerpCounter >= self.lerpTime then
			self.changingTheme = false
			self.currentTheme = self.currentDestTheme
		else
			self.lerpCounter = self.lerpCounter + dt
		end
	end
end

return ThemeSystem