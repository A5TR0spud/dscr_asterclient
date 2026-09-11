extends Label

func _ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.localization_reload.connect(refresh)

func refresh():
	text = Localizer.translate("DICT_COUNT", DictionaryHandler.word_keys.size())
