local math = require "src.utils.mathutils"

local Viewport = class("Viewport")

function Viewport:init()
	self.position = vector(0, 0)
	self.size = vector(TARGET_WIDTH, TARGET_HEIGHT)
	self.scale = 1
end

function Viewport:recalculate()
	-- scales the viewport so that it always fills the screen
	-- (some parts of the viewport may be cut off at times)
	-- must be called at least once before the game begins

	-- the target size of the game is 1280 x 720, so it'll just
	-- fit itself accordingly for different screen sizes
	local sourceWidth = TARGET_WIDTH
	local sourceHeight = TARGET_HEIGHT
	local targetWidth = love.graphics.getWidth()
	local targetHeight = love.graphics.getHeight()

	local targetRatio = targetHeight / targetWidth
	local sourceRatio = sourceHeight / sourceWidth

	if targetRatio < sourceRatio then
		self.scale = targetWidth / sourceWidth
	else
		self.scale = targetHeight / sourceHeight
	end

	self.size.x = math.round(sourceWidth * self.scale)
	self.size.y = math.round(sourceHeight * self.scale)
	self.position.x = (targetWidth - self.size.x) / 2
	self.position.y = (targetHeight - self.size.y) / 2
end

function Viewport:unproject(position)
	position = position - self.position
	position = position / SCALE_FACTOR / self.scale
	position.x, position.y = mainCamera:worldCoords(position.x, position.y)
	return position
end

function Viewport:project(position)
	position.x, position.y = mainCamera:cameraCoords(position.x, position.y)
	position = position * SCALE_FACTOR * self.scale
	position = position + self.position
	return position
end

return Viewport