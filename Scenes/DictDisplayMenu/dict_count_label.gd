extends Label

func _ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.localization_reload.connect(refresh)

func refresh():
	var keys_size = DictionaryHandler.word_keys.size()
	text = Localizer.translate_plural("DICT_COUNT", keys_size, keys_size)
