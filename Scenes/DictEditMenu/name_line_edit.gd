extends LineEdit

func _ready():
	Main.instance.reload_dict.connect(refresh)
	refresh()

func refresh():
	placeholder_text = DictionaryHandler.signals_to_words([-109, -237, -38])

func _gui_input(event):
	if event is InputEventKey:
		event = event as InputEventKey
		var uni: int = event.unicode
		if ord("a") <= uni and uni <= ord("z"):
			insert_text_at_caret(char(uni).to_upper())
			accept_event()
			return
		if uni == ord(" "):
			insert_text_at_caret("_")
			accept_event()
			return
		if uni == ord("@") or uni == ord("$") or uni == ord("|"):
			accept_event()
			return
		if uni >= ord("0") and uni <= ord("9"):
			accept_event()
			return
