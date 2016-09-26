local gameconfig = {}

gameconfig.debugMode = false
gameconfig.profileMode = false

gameconfig.currentOS = love.system.getOS()

gameconfig.render = {
	scaleFactor = 1,
	targetWidth = 800,
	targetHeight = 600,
	timeScale = 1
}

return gameconfig