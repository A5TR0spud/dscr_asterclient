extends Button
class_name BoolButton

var IsOn: bool:
	set(value):
		button_pressed = not value
	get:
		return not button_pressed

func _ready():
	Main.instance.ReloadDict.connect(refresh)

func refresh():
	text = DictionaryHandler.Signals2Words([-27])
	custom_minimum_size.x = get_minimum_size().x
	text = DictionaryHandler.Signals2Words([-28])
	custom_minimum_size.x = max(custom_minimum_size.x, get_minimum_size().x)
	text = DictionaryHandler.Signals2Words([-28 if button_pressed else -27])

func _on_toggled(toggled_on):
	text = DictionaryHandler.Signals2Words([-28 if toggled_on else -27])
