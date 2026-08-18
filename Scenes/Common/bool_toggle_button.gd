extends Button

func _ready():
	Main.instance.reload_dict.connect(refresh)
	refresh.call_deferred()

func refresh():
	text = DictionaryHandler.signals_to_words([-27])
	custom_minimum_size.x = get_minimum_size().x
	text = DictionaryHandler.signals_to_words([-28])
	custom_minimum_size.x = max(custom_minimum_size.x, get_minimum_size().x)
	text = DictionaryHandler.signals_to_words([-27 if button_pressed else -28])

func _on_toggled(toggled_on):
	text = DictionaryHandler.signals_to_words([-27 if toggled_on else -28])
