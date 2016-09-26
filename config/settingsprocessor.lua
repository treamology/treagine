local json = require "treagine.lib.JSON"

local SettingsProcessor = {}

local loadedSettings = {}
local defaultSettings = nil

local fileName = "settings.json"

function SettingsProcessor.init(name, defaults)
	defaultSettings = defaults
	love.filesystem.setIdentity(name)

	if not love.filesystem.isFile(fileName) then
		print("Settings file does not exist, creating a fresh one...")
		SettingsProcessor.saveSettings(defaultSettings)
	end
end

function SettingsProcessor.loadSettings()
	if love.filesystem.isFile(fileName) then
		local settingsJSON = love.filesystem.read(fileName)
		SettingsProcessor.loadedSettings = json:decode(settingsJSON)
	end
end

function SettingsProcessor.saveSettings(settings)
	local saveSettings = settings or SettingsProcessor.loadedSettings
	local settingsJSON = json:encode_pretty(saveSettings)

	love.filesystem.write(fileName, settingsJSON)
end

SettingsProcessor.loadedSettings = loadedSettings
SettingsProcessor.defaultSettings = defaultSettings

return SettingsProcessor