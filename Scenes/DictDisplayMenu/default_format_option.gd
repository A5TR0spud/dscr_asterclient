extends VBoxContainer

func _gui_input(event: InputEvent):
	if event is InputEventMouse:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		if DictEditMenu.instance.CURRENT_SIGNAL == 0:
			DictEditMenu.instance.visible = not DictEditMenu.instance.visible
			return
		DictEditMenu.instance.CURRENT_SIGNAL = 0
		DictEditMenu.instance.show()
