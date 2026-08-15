extends TextEdit

@onready var autocomplete_list: ItemList = $ItemList
#CodeEdit hates trying to autocomplete things without spaces, so use a nested one which contains only the word to try
@onready var autocomplete_finder: CodeEdit = $AutocompleteFinder

func _ready():
	Main.instance.reload_dict.connect(refresh)
	autocomplete_list.hide()
	autocomplete_finder.hide()

func refresh():
	placeholder_text = DictionaryHandler.signals_to_words([-43, -38])

func _request_code_completion(force: bool) -> void:
	var result_under_caret: Array = get_signal_under_caret()
	var word_under_caret: String = result_under_caret[0]
	var col_under_caret: int = result_under_caret[1]
	if word_under_caret.is_empty() and not force:
		autocomplete_list.hide()
		return
	if col_under_caret < 0:
		return
	
	#print("CHECKING: ", word_under_caret)
	
	# TODO: make this better
	# dont add every word?
	# but only if it makes it lag
	autocomplete_finder.text = word_under_caret
	autocomplete_finder.set_caret_column(word_under_caret.length() + 1)
	for word: String in (DictionaryHandler.word_names as Array[String]):
		autocomplete_finder.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, word, word)
	autocomplete_finder.update_code_completion_options(false)

	var options: Array[Dictionary] = autocomplete_finder.get_code_completion_options()
	if options.is_empty():
		autocomplete_list.hide()
		#print("NO OPTIONS FOR ", word_under_caret)
		return
	autocomplete_finder.cancel_code_completion()
	
	_show_custom_popup(options)
	autocomplete_list.reset_size.call_deferred()

func get_signal_under_caret() -> Array:
	var line_text = get_line(get_caret_line())
	var caret_col = get_caret_column()
	return DictionaryHandler.find_incomplete_signal(line_text, caret_col)

func _show_custom_popup(options: Array[Dictionary]):
	autocomplete_list.clear()
	for option in options:
		autocomplete_list.add_item(option["display_text"])
	autocomplete_list.select(0)
	
	var word = get_signal_under_caret()[0]
	var caret_line = get_caret_line()
	var caret_col = max(0, get_caret_column())
	var word_start_col = max(0, caret_col - word.length() + 1)
	
	var caret_local: Vector2i = get_rect_at_line_column(caret_line, word_start_col).position
	var caret_global: Vector2i = Vector2i(global_position) + caret_local
	
	autocomplete_list.position = caret_global
	autocomplete_list.show()

func _on_text_changed():
	_request_code_completion(false)

func _on_caret_changed():
	_request_code_completion(false)

func _confirm_selection(index: int) -> void:
	var chosen: String = autocomplete_list.get_item_text(index)
	var caret_line: int = get_caret_line()
	var minced_result: Array = get_signal_under_caret()
	var start_col: int = minced_result[1]
	while not chosen.contains(get_line(caret_line)[start_col]):
		start_col += 1
		if start_col >= get_line(caret_line).length():
			start_col = minced_result[1]
			break
	var end_col: int = start_col + minced_result[0].length()
	while not chosen.contains(get_line(caret_line)[end_col - 1]):
		end_col -= 1
		if end_col <= 0:
			end_col = start_col + minced_result[0].length()
			break

	remove_text(caret_line, start_col, caret_line, end_col)
	#set_caret_column(start_col)
	
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
		insert_text_at_caret("\n")
		accept_event()
		return
	if event.is_action_pressed("ui_paste"):
		autocomplete_list.hide()
		insert_text_at_caret(DisplayServer.clipboard_get().to_upper())
		accept_event()
		return
	if autocomplete_list.visible:
		var selected = autocomplete_list.get_selected_items()
		var idx = selected[0] if not selected.is_empty() else 0
		if event.is_action_pressed("ui_down"):
			idx = min(idx + 1, autocomplete_list.item_count - 1)
			autocomplete_list.select(idx)
			accept_event()
			autocomplete_list.get_v_scroll_bar().value += autocomplete_list.get_item_rect(idx).size.y
			return
		if event.is_action_pressed("ui_up"):
			idx = max(idx - 1, 0)
			autocomplete_list.select(idx)
			accept_event()
			autocomplete_list.get_v_scroll_bar().value -= autocomplete_list.get_item_rect(idx).size.y
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
	
	if event is InputEventKey:
		event = event as InputEventKey
		if "a".unicode_at(0) <= event.unicode and event.unicode <= "z".unicode_at(0):
			insert_text_at_caret(char(event.unicode).to_upper())
			accept_event()
			return
		

func _on_item_list_item_clicked(index, _at_position, mouse_button_index):
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	_confirm_selection(index)
