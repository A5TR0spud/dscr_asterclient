extends VBoxContainer
class_name SettingEntry

@export var description: Array = []
@export var state: bool:
	get:
		if bool_button == null:
			await ready
		return bool_button.button_pressed
	set(value):
		if bool_button == null:
			await ready
		bool_button.button_pressed = value

@onready var description_label: Label = $Description
@onready var equals_label: Label = $BoolOption/Equals
@onready var bool_button: BoolButton = $BoolOption/BoolButton

func set_state_no_signal(val: bool):
	bool_button.set_pressed_no_signal(val)
	bool_button.refresh()

func _ready():
	Main.instance.reload_dict.connect(refresh)
	bool_button.set_pressed_no_signal(state)
	bool_button.refresh()
	refresh()

func refresh():
	var o: Array = description.duplicate()
	o.insert(0, -26)
	o.insert(1, -14)
	o.append(-15)
	description_label.text = DictionaryHandler.signals_to_words(o)
	equals_label.text = DictionaryHandler.get_or_default_signal_name(-4)

func _on_bool_button_toggled(_toggled_on):
	emit_signal("set", state)

signal set(new_value: bool)
