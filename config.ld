project = 'treagine'
format = 'markdown'

full_description = 'An engine that builds on top of Love2D.'
file = {'.', exclude = {'lib'} }

custom_tags = { { 'ivar', title = 'Instance Variables' } }

custom_display_name_handler = function(item, default_handler)
	module(..., package.seeall)
	if item.tags.ivar then
		return string.gsub(item.name, "self.", "")
	end
	return default_handler(item)
end