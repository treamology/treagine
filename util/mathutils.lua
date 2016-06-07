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

return mathutils