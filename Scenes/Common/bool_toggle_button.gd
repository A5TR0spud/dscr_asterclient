extends Button
class_name BoolButton

@export var off_text: Array[int] = [-28]
@export var on_text: Array[int] = [-27]

func _ready():
	Main.instance.reload_dict.connect(refresh)
	refresh.call_deferred()

func refresh():
	text = DictionaryHandler.signals_to_words(on_text)
	custom_minimum_size.x = get_minimum_size().x
	text = DictionaryHandler.signals_to_words(off_text)
	custom_minimum_size.x = max(custom_minimum_size.x, get_minimum_size().x)
	text = DictionaryHandler.signals_to_words(on_text if button_pressed else off_text)

func _toggled(toggled_on):
	text = DictionaryHandler.signals_to_words(on_text if toggled_on else off_text)
