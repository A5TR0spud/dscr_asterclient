extends RefCounted
class_name Localizer

static func get_m0_string(key: String) -> String:
	return TranslationServer.find_translations("m0", true)[0].get_message(key)

static func translate(key: String, arguments: Variant = []) -> String:
	if arguments is not Array and arguments is not Dictionary:
		arguments = [arguments]
	if SettingsHandler.use_m0_ui and DictionaryHandler.support_m0:
		var translation: String = get_m0_string(key)
		if translation:
			var arr: Array = translation.split(" ")
			for idx in range(arr.size()):
				if str(arr[idx]).is_valid_int():
					arr[idx] = str(arr[idx]).to_int()
			return DictionaryHandler.signals_to_words(arr).format(arguments)
	return TranslationServer.translate(key).format(arguments)

static func translate_plural(key: String, n: int, arguments: Variant = []) -> String:
		if SettingsHandler.use_m0_ui and DictionaryHandler.support_m0:
			return translate(key, arguments)
		if n < 0:
			n = 0
		var translation: String = TranslationServer.translate_plural(key, "", n);
		if arguments is not Array and arguments is not Dictionary:
			arguments = [arguments]
		return translation.format(arguments)

## Returns an array with 1 string if not in meteorese.
## Returns an array of signals (with parsing strings) if in meteorese
static func raw_translate(key: String) -> Array:
	if SettingsHandler.use_m0_ui and DictionaryHandler.support_m0:
		var translation: String = get_m0_string(key)
		if translation:
			return _raw_translate_m0(translation)
	return [TranslationServer.translate(key)]
	
static func raw_translate_plural(key: String, n: int) -> Array:
	if TranslationServer.get_locale() == "m0":
		var translation: String = TranslationServer.translate(key)
		return _raw_translate_m0(translation)
	else:
		return [TranslationServer.translate_plural(key, "", n)]

static func _raw_translate_m0(translation: String) -> Array:
	var arr: Array = translation.split(" ")
	for idx in range(arr.size()):
		if str(arr[idx]).is_valid_int():
			arr[idx] = str(arr[idx]).to_int()
		else:
			arr[idx] = str(arr[idx])
	return arr
