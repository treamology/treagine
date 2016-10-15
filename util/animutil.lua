local json = require "treagine.lib.JSON"
local anim8 = require "treagine.lib.anim8"
local vector = require "treagine.lib.vector"

local animutil = {}

local animDataCache = {}

function animutil.importAnimations(name)
	local animData, fromCache
	if animDataCache[name] then
		-- just load what's in the cache
		animData = animDataCache[name]
		fromCache = true
	else
		-- load up the json and decode it, then cache it
		local rawJSON = love.filesystem.read("assets/sprites/data/" .. name .. ".json")
		assert(rawJSON ~= nil, "Could not read the JSON file for " .. name)
		animData = json:decode(rawJSON)
		animDataCache[name] = animData
		fromCache = false
	end

	-- extract needed data from the sorted frames
	if not fromCache then
		local frameData = {}
		for _, frame in pairs(animData.frames) do
			local frameInfo = frame.frame

			local out = {}
			out.x = frameInfo.x
			out.y = frameInfo.y
			out.w = frameInfo.w
			out.h = frameInfo.h
			out.duration = frame.duration

			out.xLoc = out.x / out.w
			out.yLoc = out.y / out.h

			table.insert(frameData, out)
		end

		-- sort the frames based on their position in the image.
		table.sort(frameData, function(a, b)
			return a.y < b.y or (a.y == b.y and a.x < b.x)
		end)

		animData.frameData = frameData
	end

	-- for now, all the frames have to be the same size
	-- support for multiple grids can be added later.
	local frameSize = vector(animData.frameData[1].w, animData.frameData[2].h)
	local image = love.graphics.newImage("assets/sprites/" .. name .. ".png")
	assert(image ~= nil, "Could not read the image for " .. name)
	local grid = anim8.newGrid(frameSize.x, frameSize.y, image:getDimensions())

	local function createDurations(from, to)
		local durations = {}
		for i = from, to do
			table.insert(durations, animData.frameData[i].duration / 1000)
		end
		return durations
	end
	local function getCoordinates(from, to)
		local coords = {}
		for i = from, to do
			table.insert(coords, animData.frameData[i].xLoc + 1)
			table.insert(coords, animData.frameData[i].yLoc + 1)
		end
		return unpack(coords)
	end

	-- finally, create the anim8 animations from the frame data
	local animTable = {}
	for _, tag in pairs(animData.meta.frameTags) do
		local xStart = animData.frameData[tag.from]
		animTable[tag.name] = anim8.newAnimation(grid(getCoordinates(tag.from + 1, tag.to + 1)), createDurations(tag.from + 1, tag.to + 1))
	end

	return image, animTable, frameSize
end

return animutil