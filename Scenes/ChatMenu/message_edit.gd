extends CodeEdit

@onready var popup_node: PopupPanel = $PopupPanel
@onready var autocomplete_list: ItemList = $PopupPanel/ItemList

func _input(event: InputEvent):
	if event.is_action_pressed("ui_text_submit") and not event.is_action_pressed("ui_text_newline"):
		if Main.instance.send_message(text):
			text = ""
	if event.is_action_pressed("ui_text_completion_accept"):
		pass

func _ready():
	Main.instance.reload_dict.connect(refresh)
	popup_node.unfocusable = true

func refresh():
	placeholder_text = DictionaryHandler.signals_to_words([-43, -38])

func _request_code_completion(force: bool) -> void:
	var word_under_caret = get_word_under_caret()
	if word_under_caret.is_empty() and not force:
		return
	
	# TODO: make this better
	# dont add every word?
	# but only if it makes it lag
	for word: String in (DictionaryHandler.word_names as Array[String]):
		add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, word, word)
	update_code_completion_options(true)
	
	var options: Array[Dictionary] = get_code_completion_options()
	if options.is_empty():
		popup_node.hide()
		return
	cancel_code_completion()
	
	
	_show_custom_popup(options)

func _show_custom_popup(options: Array[Dictionary]):
	autocomplete_list.clear()
	for option in options:
		autocomplete_list.add_item(option["display_text"])
	autocomplete_list.select(0)
	
	var word = get_word_under_caret()
	var caret_line = get_caret_line()
	var caret_col = get_caret_column()
	var word_start_col = caret_col - word.length()
	
	var caret_local: Vector2 = get_pos_at_line_column(caret_line, word_start_col)
	var caret_global: Vector2 = global_position + caret_local
	var line_h: float = get_line_height()
	
	var visible_items = min(options.size(), 8)
	
	var popup_height = 152#visible_items * (SettingsHandler.font_size + 3)
	## font size = 15 s = 18
	# au 8 -> 144
	# tp 7 -> 126
	# pona 6 ->
	# ou 5 ->
	# tpr 4 ->
	# av 3 ->
	# tprt 2 ->
	# vv 1 -> 18
	## font size = 18 s = 22
	# au 8 -> 176
	# tp 7 -> 154
	# pona 6 ->
	# ou 5 ->
	# tpr 4 ->
	# av 3 ->
	# tprt 2 ->
	# vv 1 ->
	## f17 s21
	## f16 s19
	autocomplete_list.reset_size()
	prints(
		autocomplete_list.get_item_rect(0	),
		autocomplete_list.get_theme_constant("v_separation")
		)
	#print(popup_height)
	var popup_width = 240
	
	popup_node.size = Vector2i(popup_width, popup_height)
	
	popup_node.position = Vector2i(
			int(caret_global.x),
			int(caret_global.y - popup_height - line_h)
	)
	
	popup_node.popup()

func _on_text_changed():
	var col := get_caret_column()
	var lin := get_caret_line()
	text = text.to_upper()
	set_caret_column(col)
	set_caret_line(lin)
	_request_code_completion(false)
	
