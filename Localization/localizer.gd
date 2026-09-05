extends RefCounted
class_name Localizer

static func translate(key: String, arguments: Variant = []) -> String:
	var translation: String = TranslationServer.translate(key)
	if arguments is not Array and arguments is not Dictionary:
		arguments = [arguments]
	if TranslationServer.get_locale() == "m0":
		var arr: Array = translation.split(" ")
		for idx in range(arr.size()):
			if str(arr[idx]).is_valid_int():
				arr[idx] = str(arr[idx]).to_int()
		translation = DictionaryHandler.signals_to_words(arr)
	return translation.format(arguments)

## Returns an array with 1 string if not in meteorese.
## Returns an array of signals (with parsing strings) if in meteorese
static func raw_translate(key: String) -> Array:
	var translation: String = TranslationServer.translate(key)
	if TranslationServer.get_locale() == "m0":
		var arr: Array = translation.split(" ")
		for idx in range(arr.size()):
			if str(arr[idx]).is_valid_int():
				arr[idx] = str(arr[idx]).to_int()
			else:
				arr[idx] = str(arr[idx])
		return arr
	return [translation]
