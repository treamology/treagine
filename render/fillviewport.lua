local class = require "treagine.lib.30log"
local vector = require "treagine.lib.vector"

local math = require "treagine.util.mathutils"
local gameconfig = require "treagine.config.gameconfig"

local FillViewport = class("FillViewport")

function FillViewport:init()
	self.position = vector(0, 0)
	self.size = vector(gameconfig.render.targetWidth, gameconfig.render.targetHeight)
	self.scale = 1

	return self
end

function FillViewport:recalculate()
	-- scales the viewport so that it always fills the screen
	-- (some parts of the viewport may be cut off at times)
	-- must be called at least once before the game begins
	
	local sourceWidth = gameconfig.render.targetWidth
	local sourceHeight = gameconfig.render.targetHeight
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

function FillViewport:unproject(position)
	position = position - self.position
	position = position / gameconfig.render.scaleFactor / self.scale
	
	if self.camera then
		position.x, position.y = self.camera:worldCoords(position.x, position.y)
	end

	return position
end

function FillViewport:project(position)
	if self.camera then
		position.x, position.y = self.camera:cameraCoords(position.x, position.y)
	end

	position = position * gameconfig.render.scaleFactor * self.scale
	position = position + self.position
	
	return position
end

function FillViewport:projectLight(x, y)
	local rx, ry = 0, 0
	
	if self.camera then
		rx, ry = self.camera:cameraCoords(x, y)
	end

	rx = (rx * gameconfig.render.scaleFactor * self.scale) + self.position.x
	ry = (ry * gameconfig.render.scaleFactor * self.scale) + self.position.y

	return rx, ry
end

function FillViewport:unprojectLight(x, y)
	x = x - self.position.x
	y = y - self.position.y

	x = x / gameconfig.render.scaleFactor / self.scale
	y = y / gameconfig.render.scaleFactor / self.scale

	if self.camera then
		x, y = self.camera:worldCoords(x, y)
	end

	return x, y
end

function FillViewport:projectScale(scale)
	scale = scale * gameconfig.render.scaleFactor * self.scale
	return scale
end

return FillViewport