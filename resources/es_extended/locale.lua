Locales = {}

_ = function(str, ...)  -- Translate string

	if Locales[Config.Locale] ~= nil then

		if Locales[Config.Locale][str] ~= nil then
			return string.format(Locales[Config.Locale][str], ...)
		else
			return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
		end

	else
		return 'Locale [' .. Config.Locale .. '] does not exist'
	end

end

_U = (str, ...) -- Translate string first char uppercase
	local translated = _(str, ...);
	return tostring(translated:gsub("^%l", string.upper))
end
