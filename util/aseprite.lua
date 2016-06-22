local json = require "treagine.lib.JSON"
local anim8 = require "treagine.lib.anim8"

local Aseprite = {}


function Aseprite.importAnimation(name)
	-- load up the json and decode it so it can be read like a table
	local rawJSON = love.filesystem.read("assets/sprites/data/" .. name .. ".json")
	local animData = json:decode(rawJSON)

	-- seperate the frames from their keys and sort them by position in the image.
	-- this needs to be done because by default the frames are in an arbitrary order in animData
	local sortedFrames = {}
	for _, v in pairs(animData.frames) do
		table.insert(sortedFrames, v)
	end
	table.sort(sortedFrames, function(a, b)
		return a.frame.x < b.frame.x
	end)

	-- extract needed data from the sorted frames
	local frames = {}
	for _, frame in pairs(sortedFrames) do
		local frameInfo = frame.frame

		local out = {}
		out.x = frameInfo.x
		out.y = frameInfo.y
		out.w = frameInfo.w
		out.h = frameInfo.h
		out.duration = frame.duration

		table.insert(frames, out)
	end

	-- for now, all the frames have to be the same size
	-- support for multiple grids can be added later.
	local image = love.graphics.newImage("assets/sprites/" .. name .. ".png")
	local grid = anim8.newGrid(frames[1].w, frames[2].h, image:getDimensions())

	local function createDurations(from, to)
		local durations = {}
		for i = from, to do
			table.insert(durations, frames[i].duration / 1000)
		end
		return durations
	end

	-- finally, create the anim8 animations from the frame data
	local animTable = {}
	for _, tag in pairs(animData.meta.frameTags) do
		animTable[tag.name] = anim8.newAnimation(grid(tag.from + 1 .. "-" .. tag.to + 1, 1), createDurations(tag.from + 1, tag.to + 1))
	end

	return image, animTable
end

return Aseprite