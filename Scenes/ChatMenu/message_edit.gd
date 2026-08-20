extends TextEdit

@onready var autocomplete_list: ItemList = $PanelContainer/MarginContainer/ItemList
@onready var auto_list_panel: PanelContainer = $PanelContainer
const DELIMITER_CHARACTER = "\u001f"

func _ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.reload_settings.connect(_set_popup_size.call_deferred)
	auto_list_panel.hide()

func refresh():
	placeholder_text = DictionaryHandler.signals_to_words([-43, -38])

func submit_text() -> void:
	var send_result: Array = Main.instance.send_message(text.remove_char(ord(DELIMITER_CHARACTER)))
	if send_result[0]:
		text = ""
	match send_result[1]:
		Main.MessageCompilationResult.MESSAGE_SENT:
			SoundManager.play_sound(SoundManager.Sounds.MESSAGE_SENT)
		Main.MessageCompilationResult.MESSAGE_FAILED:
			SoundManager.play_sound(SoundManager.Sounds.FAIL)
		Main.MessageCompilationResult.COMMAND_SENT:
			SoundManager.play_sound(SoundManager.Sounds.COMMAND_ACCEPTED)
		Main.MessageCompilationResult.SHOW_SENT:
			SoundManager.play_sound(SoundManager.Sounds.OPEN_UI)
		Main.MessageCompilationResult.HIDE_SENT:
			SoundManager.play_sound(SoundManager.Sounds.CLOSE_UI)
		Main.MessageCompilationResult.REDUNDANT:
			SoundManager.play_sound(SoundManager.Sounds.REDUNDANT)

func _request_code_completion(force: bool) -> void:
	var word_under_caret: String = get_signal_under_caret()
	if word_under_caret.is_empty() and not force:
		auto_list_panel.hide()
		return
	
	var options: Array[String] = AutocompleteManager.get_candidates(word_under_caret)
	if options.is_empty():
		#print("NO OPTIONS FOR ", word_under_caret)
		auto_list_panel.hide()
		return
	if options.size() == 1 and options[0] == word_under_caret:
		auto_list_panel.hide()
		var bounds: Array = get_signal_bounds_under_caret()
		var line: String = get_line(get_caret_line())
		if bounds[1] < line.length():
			if is_signal_separating_character(line[bounds[1]]):
				return
		insert_text(DELIMITER_CHARACTER, get_caret_line(), bounds[1])
		return
	
	_show_custom_popup(options)

func is_signal_separating_character(character: String) -> bool:
	return (character == DELIMITER_CHARACTER) or (character in " \n\t\r")

## gets signal under the caret
## returns starting column and ending column as an array
func get_signal_bounds_under_caret() -> Array:
	var line_text = get_line(get_caret_line())
	var caret_col = get_caret_column()
	if caret_col == 0:
		return [0, 0]
		
	var start = caret_col - 1
	while start >= 0 and not is_signal_separating_character(line_text[start]):
		start -= 1
	
	var end = caret_col
	while end < line_text.length() and not is_signal_separating_character(line_text[end]):
		end += 1
	
	start += 1
	return [start, end]

func get_signal_under_caret() -> String:
	var line_text = get_line(get_caret_line())
	var bounds = get_signal_bounds_under_caret()
	return line_text.substr(bounds[0], bounds[1] - bounds[0])

func _show_custom_popup(options: Array[String]):
	autocomplete_list.clear()
	for option in options:
		autocomplete_list.add_item(option)
	autocomplete_list.select(0)
	
	var word = get_signal_under_caret()
	var caret_line = get_caret_line()
	var caret_col = max(0, get_caret_column())
	var word_start_col = max(0, caret_col - word.length() + 1)
	
	var caret_local: Vector2i = get_rect_at_line_column(caret_line, word_start_col).position
	var caret_global: Vector2i = Vector2i(global_position) + caret_local
	
	auto_list_panel.position = caret_global
	auto_list_panel.show()
	_set_popup_size.call_deferred()

func _set_popup_size():
	if not auto_list_panel.visible:
		return
	# TODO: add option for max autocomplete entry amount
	autocomplete_list.custom_maximum_size.y = autocomplete_list.get_item_rect(0).size.y * 8 - 1
	autocomplete_list.reset_size()
	auto_list_panel.reset_size()

func _on_text_changed():
	_request_code_completion(false)

func _on_caret_changed():
	_request_code_completion(false)

func _confirm_selection(index: int) -> void:
	var chosen: String = autocomplete_list.get_item_text(index)
	var caret_line: int = get_caret_line()
	var bounds = get_signal_bounds_under_caret()
	
	remove_text(caret_line, bounds[0], caret_line, bounds[1])
	
	# TODO: get the correct signal formatting here
	var end_formatting = " "
	insert_text_at_caret(chosen + DELIMITER_CHARACTER + end_formatting)
	auto_list_panel.hide()
	autocomplete_list.get_v_scroll_bar().value = 0

## find delimiter index near the caret, -1 if not found
func find_delimiter_near(line: String, col: int) -> int:
	if col > 0 and line[col - 1] == DELIMITER_CHARACTER:
		return col - 1 # thing@|thing@
	if col < line.length() and line[col] == DELIMITER_CHARACTER:
		return col     # thing|@thing@
	return -1

func _gui_input(event: InputEvent) -> void:
	# TODO: implement brace matching (handling), so that it can parse |-14 and |-15 if they are group symbols
	if event.is_action_pressed("ui_text_newline"):
		insert_text_at_caret("\n")
		accept_event()
		return
	if event.is_action_pressed("ui_copy"):
		var selected_text = get_selected_text().remove_char(ord(DELIMITER_CHARACTER))
		DisplayServer.clipboard_set(selected_text)
		accept_event()
		return
	if event.is_action_pressed("ui_cut"):
		var selected_text = get_selected_text().remove_char(ord(DELIMITER_CHARACTER))
		if selected_text != "":
			DisplayServer.clipboard_set(selected_text)
			delete_selection()
			text_changed.emit()
		accept_event()
		return
	if event.is_action_pressed("ui_paste"):
		auto_list_panel.hide()
		insert_text_at_caret(DisplayServer.clipboard_get().to_upper())
		accept_event()
		return
	if auto_list_panel.visible:
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
		if event.is_action_pressed("autocomplete_accept"):
			_confirm_selection(idx)
			accept_event()
			return
		if event.is_action_pressed("ui_close_dialog"):
			auto_list_panel.hide()
			accept_event()
			return
	
	# TODO: history implementation here
	
	if event.is_action_pressed("ui_text_submit"):
		auto_list_panel.hide()
		submit_text()
		accept_event()
		return
	
	if event is InputEventKey:
		event = event as InputEventKey
		
		var line = get_caret_line()
		var line_text = get_line(line)
		var col = get_caret_column()
		var no_selection = get_selected_text().is_empty()
		
		if event.is_action_pressed("ui_text_caret_right") and (no_selection or event.shift_pressed):
			if col < line_text.length() and line_text[col] == DELIMITER_CHARACTER:
				set_caret_column(min(col + 2, line_text.length()))
				accept_event()
				if no_selection and event.shift_pressed:
					select(line, col, line, col + 2)
				return
		if event.is_action_pressed("ui_text_caret_left") and (no_selection or event.shift_pressed):
			if col > 0 and line_text[col - 1] == DELIMITER_CHARACTER:
				set_caret_column(max(col - 2, 0))
				accept_event()
				if no_selection and event.shift_pressed:
					select(line, col, line, col - 2)
				return
		
		if event.is_action_pressed("ui_text_backspace") and get_selected_text() == "":
			var delimiter_index = find_delimiter_near(line_text, col)
			if delimiter_index != -1 and delimiter_index > 0:
				# erase delimiter character as well
				var start = delimiter_index - 1
				remove_text(line, start, line, delimiter_index + 1)
				set_caret_column(start)
				text_changed.emit()
				accept_event()
				return
		if event.is_action_pressed("ui_text_delete") and get_selected_text() == "":
			var delimiter_index = find_delimiter_near(line_text, col + 1)
			if delimiter_index != -1 and delimiter_index > 0:
				# erase delimiter character as well
				var start = delimiter_index - 1
				remove_text(line, start, line, delimiter_index + 1)
				set_caret_column(start)
				text_changed.emit()
				accept_event()
				return
		# do not put ui_accept here! this is tab specific! ui_accept includes enter and space too
		# removes the delimiter and brings up the autocomplete menu
		# TODO:
		# this is still not exactly what i want, it should remove the whitespace that comes before it too,
		# so the caret points to the signal you wanted to edit
		if event.keycode == KEY_TAB and not event.shift_pressed:
			var delimiter_index = find_delimiter_near(line_text, col)
			if delimiter_index != -1:
				remove_text(line, delimiter_index, line, delimiter_index + 1)
				set_caret_column(delimiter_index if col > delimiter_index else col)
				text_changed.emit()
			accept_event()
			return
			
		if ord("a") <= event.unicode and event.unicode <= ord("z"):
			if event.ctrl_pressed or event.meta_pressed or event.alt_pressed:
				return
			insert_text_at_caret(char(event.unicode).to_upper())
			text_changed.emit()
			accept_event()
			return

func _on_item_list_item_clicked(index, _at_position, mouse_button_index):
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	_confirm_selection(index)
