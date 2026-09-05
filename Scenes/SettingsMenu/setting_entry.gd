extends VBoxContainer
class_name SettingEntry

@export var description: String = "SETTINGS_"
@export var state: bool:
	get:
		if bool_button == null:
			return false
		return bool_button.button_pressed
	set(value):
		if bool_button == null:
			return
		bool_button.button_pressed = value

@onready var description_label: Label = $Description
@onready var bool_button: BoolButton = $BoolButton

func set_state_no_signal(val: bool):
	bool_button.set_pressed_no_signal(val)
	bool_button.refresh()

func _ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.localization_reload.connect(refresh)
	bool_button.set_pressed_no_signal(state)
	bool_button.refresh()
	refresh()

func refresh():
	description_label.text = Localizer.translate(description)

func _on_bool_button_toggled(_toggled_on):
	emit_signal("set", state)

signal set(new_value: bool)
