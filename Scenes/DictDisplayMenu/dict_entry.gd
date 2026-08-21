extends VBoxContainer
class_name DictEntry

var sig: int = 0

@onready var signal_label: Label = $Entry/Signal
@onready var meaning_label: Label = $Entry/Meaning

func _ready():
	signal_label.text = String.num_int64(sig)
	meaning_label.text = DictionaryHandler.get_or_default_signal_name(sig)

func _gui_input(event: InputEvent):
	if event is InputEventMouse:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		DictEditMenu.open(sig, true)
