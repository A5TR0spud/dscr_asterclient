extends LineEdit
func _ready():
	Main.instance.reload_dict.connect(refresh)
	refresh()

func refresh():
	placeholder_text = DictionaryHandler.get_or_default_signal_name(-260)

func _gui_input(event):
	if event is InputEventKey:
		event = event as InputEventKey
		var uni: int = event.unicode
		if ((uni >= 32 and uni < 45)
			or (uni > 45 and uni < 48)
			or (uni > 57 and uni < 127)
			or (uni > 127)
		):
			accept_event()
			return
