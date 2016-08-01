local autocache = {}

local new_image = love.graphics.newImage
local new_font = love.graphics.newFont
local new_image_font = love.graphics.newImageFont

local cachedImages = {}
local cachedFonts = {}

local function newImage(name, ...)
	if type(name) ~= "string" then
		return new_image(name, ...)
	end

	if cachedImages[name] == nil then
		print("Loading image " .. name)
		cachedImages[name] = new_image(name, ...)
	end

	return cachedImages[name]
end

local function newFont(name, ...)
	if cachedFonts[name] == nil then
		print("Loading font " .. name)
		cachedFonts[name] = new_font(name, ...)
	end

	return cachedFonts[name]
end

local function newImageFont(name, ...)
	if cachedFonts[name] == nil then
		print("Loading font " .. name)
		cachedFonts[name] = new_image_font(name, ...)
	end

	return cachedFonts[name]
end

love.graphics.newImage = newImage
love.graphics.newFont = newFont
love.graphics.newImageFont = newImageFont

autocache.cachedImages = cachedImages
autocache.cachedFonts = cachedFonts

return autocache