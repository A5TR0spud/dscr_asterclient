extends CodeEdit

func _input(event: InputEvent):
	if event.is_action_pressed("ui_text_submit") and not event.is_action_pressed("ui_text_newline"):
		if Main.instance.send_message(text):
			text = ""
	if event.is_action_pressed("ui_text_completion_accept"):
		pass

func _ready():
	Main.instance.reload_dict.connect(refresh)

func refresh():
	placeholder_text = DictionaryHandler.signals_to_words([-43, -38])

func _on_text_changed():
	var col := get_caret_column()
	var lin := get_caret_line()
	text = text.to_upper()
	set_caret_column(col)
	set_caret_line(lin)
