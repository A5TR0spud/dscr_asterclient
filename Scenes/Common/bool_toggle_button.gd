extends Button
class_name BoolButton

@export var off_text: String = "SETTINGS_BOOL_FALSE"
@export var on_text: String = "SETTINGS_BOOL_TRUE"

func _ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.localization_reload.connect(refresh)
	refresh.call_deferred()

func refresh():
	text = Localizer.translate(on_text)
	custom_minimum_size.x = get_minimum_size().x
	text = Localizer.translate(off_text)
	custom_minimum_size.x = max(custom_minimum_size.x, get_minimum_size().x)
	text = Localizer.translate(on_text if button_pressed else off_text)

func _toggled(toggled_on):
	text = Localizer.translate(on_text if toggled_on else off_text)
