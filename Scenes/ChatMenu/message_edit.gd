extends CodeEdit

@onready var autocomplete_list: ItemList = $ItemList

func _ready():
	Main.instance.reload_dict.connect(refresh)
	autocomplete_list.hide()

func refresh():
	placeholder_text = DictionaryHandler.signals_to_words([-43, -38])

func _request_code_completion(force: bool) -> void:
	var word_under_caret = get_signal_under_caret()
	if word_under_caret.is_empty() and not force:
		autocomplete_list.hide()
		return
	
	# TODO: make this better
	# dont add every word?
	# but only if it makes it lag
	for word: String in (DictionaryHandler.word_names as Array[String]):
		add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, word, word)
	update_code_completion_options(true)
	
	var options: Array[Dictionary] = get_code_completion_options()
	if options.is_empty():
		autocomplete_list.hide()
		#print("NO OPTIONS FOR ", word_under_caret)
		return
	cancel_code_completion()
	
	_show_custom_popup(options)

func get_signal_under_caret():
	# go back until you hit a space
	
	# TODO: implement the following, but its too annoying
	# if there is a signal there already
	# like VAR_0 and the 0 isnt typed yet,
	# ignore the signal
	var line_text = get_line(get_caret_line())
	var caret_col = get_caret_column()
	
	var best = ""
	var start = caret_col - 1
	while start >= 0 and line_text[start] != " ":
		var potential_signal = line_text.substr(start, caret_col - start)
		#print("pot",start, potential_signal)
		#if potential_signal in DictionaryHandler.word_names:
		#	start += potential_signal.length()
		#	best = line_text.substr(start, caret_col - start)
		#	
		#	print("found signal ", potential_signal, " replaced ", best)
		#	break
		best = potential_signal
		start -= 1
	#print("'",best,"'")
	return best

func _show_custom_popup(options: Array[Dictionary]):
	autocomplete_list.clear()
	for option in options:
		autocomplete_list.add_item(option["display_text"])
	autocomplete_list.select(0)
	
	var word = get_signal_under_caret()
	var caret_line = get_caret_line()
	var caret_col = get_caret_column()
	var word_start_col = caret_col - word.length() + 1
	
	var caret_local: Vector2 = get_pos_at_line_column(caret_line, word_start_col)
	var caret_global: Vector2 = global_position + caret_local
	var line_h: float = get_line_height()
	
	autocomplete_list.position = Vector2i(
			int(caret_global.x),
			int(caret_global.y - line_h)
	)
	autocomplete_list.reset_size.call_deferred()
	autocomplete_list.show()

func _on_text_changed():
	var col := get_caret_column()
	var lin := get_caret_line()
	text = text.to_upper()
	set_caret_column(col)
	set_caret_line(lin)
	_request_code_completion(false)

func _confirm_selection(index: int) -> void:
	var chosen = autocomplete_list.get_item_text(index)
	var word = get_signal_under_caret()
	var caret_line = get_caret_line()
	var caret_col = get_caret_column()
	var start_col = caret_col - word.length()

	remove_text(caret_line, start_col, caret_line, caret_col)
	set_caret_column(start_col)
	
	# this deliberately ignores preferred signal formatting
	# because figuring out whatever signal comes before is 
	# too annoying. for example:
	# MOLECULE(1ATOM is clearly 4 signals
	# but its hard to find for a computer
	# especially since it needs to autocomplete whatever comes after!
	# so i just add a space and ignore it.
	insert_text_at_caret(chosen + " ")
	autocomplete_list.hide()
	autocomplete_list.get_v_scroll_bar().value = 0

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_newline"):
		return
	if autocomplete_list.visible:
		var selected = autocomplete_list.get_selected_items()
		var idx = selected[0] if not selected.is_empty() else 0

		if autocomplete_list.visible:
			if event.is_action_pressed("ui_down"):
				idx = min(idx + 1, autocomplete_list.item_count - 1)
				autocomplete_list.select(idx)
				accept_event()
				return
			if event.is_action_pressed("ui_up"):
				idx = max(idx - 1, 0)
				autocomplete_list.select(idx)
				accept_event()
				return
			if event.is_action_pressed("ui_accept"):
				_confirm_selection(idx)
				accept_event()
				return
			if event.is_action_pressed("ui_close_dialog"):
				autocomplete_list.hide()
				accept_event()
				return
	
	# TODO: history implementation here
	
	if event.is_action_pressed("ui_text_submit"):
		if Main.instance.send_message(text):
			text = ""
		accept_event()
		return

func _on_item_list_item_clicked(index, _at_position, mouse_button_index):
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	_confirm_selection(index)
