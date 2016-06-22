local json = require "treagine.lib.JSON"
local anim8 = require "treagine.lib.anim8"

local Aseprite = {}


function Aseprite.importAnimation(name)

	local rawJSON = love.filesystem.read("assets/sprites/data/" .. name .. ".json")
	local animData = json:decode(rawJSON)

	local frames = {}

	for _, frame in pairs(animData.frames) do
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
			table.insert(durations, frames[i].duration)	
		end
		return durations
	end

	local animTable = {}

	for _, tag in pairs(animData.meta.frameTags) do
		animTable[tag.name] = anim8.newAnimation(grid(tag.from + 1 .. "-" .. tag.to + 1, 1), createDurations(tag.from + 1, tag.to + 1))
	end

	return animTable
end

return Aseprite