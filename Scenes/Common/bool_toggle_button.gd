extends Button
class_name BoolButton

@export var is_on: bool:
	set(value):
		button_pressed = not value
	get:
		return not button_pressed

func _ready():
	Main.instance.reload_dict.connect(refresh)

func refresh():
	text = DictionaryHandler.signals_to_words([-27])
	custom_minimum_size.x = get_minimum_size().x
	text = DictionaryHandler.signals_to_words([-28])
	custom_minimum_size.x = max(custom_minimum_size.x, get_minimum_size().x)
	text = DictionaryHandler.signals_to_words([-28 if button_pressed else -27])

func _on_toggled(toggled_on):
	text = DictionaryHandler.signals_to_words([-28 if toggled_on else -27])
