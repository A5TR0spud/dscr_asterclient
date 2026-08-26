extends Label
class_name LibraryEntry

var trans_name: String = ""

func _ready():
	text = trans_name

func _gui_input(event: InputEvent):
	if event is InputEventMouse:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		Library.open_transmission(trans_name)
