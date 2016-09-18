local vector = require "treagine.lib.vector"

local mathutils = {}

function mathutils.lerpColors(baseColor, targetColor, progress)
	lerpedColor = {}
	if progress > 1 then
		lerpedColor = targetColor
	else
		lerpedColor[1] = baseColor[1] + (progress * (targetColor[1] - baseColor[1]))
		lerpedColor[2] = baseColor[2] + (progress * (targetColor[2] - baseColor[2]))
		lerpedColor[3] = baseColor[3] + (progress * (targetColor[3] - baseColor[3]))
		lerpedColor[4] = baseColor[4] + (progress * (targetColor[4] - baseColor[4]))
	end
	return lerpedColor
end

function mathutils.lerp(beginning, target, progress)
	return beginning + progress * (target - beginning)
end

function mathutils.round(num)
	return math.floor(num + 0.5)
end

function mathutils.radiansToHeading(radians)
	local x = math.cos(radians)
	local y = math.sin(radians)
	return vector(x, y)
end

function mathutils.headingToRadians(heading)
	return math.atan2(heading.y, heading.x)
end

function mathutils.pointInsideRect(x, y, boundX, boundY, boundW, boundH)
	if x > boundX and y < boundY + boundW and y > boundY and y < boundY + boundH then
        return true
    end
    return false
end

function mathutils.distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

return mathutils