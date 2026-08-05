extends VBoxContainer
class_name Chat

static var instance: Chat

func _enter_tree():
	instance = self

func _gui_input(event: InputEvent):
	if event is InputEventMouse:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		DictEditMenu.instance.hide()
