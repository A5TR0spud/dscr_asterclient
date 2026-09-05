extends LineEdit
class_name FilteredLineEdit

@export var deny_list: String = "@$|0123456789"
@export var allow_list: bool = false
@export var replace_list: Dictionary = {" ": "_"}
@export var capitalize: bool = true

func _filter_paste() -> void:
	var new_text: String = text
	var column: int = caret_column
	if capitalize:
		new_text = new_text.to_upper()
	for key in replace_list.keys():
		new_text.replace_char(ord(key), ord(replace_list[key]))
	if allow_list:
		for idx in range(new_text.length() - 1, -1, -1):
			if not deny_list.contains(new_text[idx]):
				new_text = new_text.erase(idx)
	else:
		new_text = new_text.remove_chars(deny_list)
	if new_text != text:
		text = new_text
		caret_column = column

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_paste"):
		_filter_paste.call_deferred()
		return
	if event is InputEventKey and event.is_pressed():
		event = event as InputEventKey
		var uni: int = event.unicode
		#print("before: ", char(uni), " ", uni, " ", event.as_text_keycode(), " ", event.get_keycode_with_modifiers())
		if uni <= 31:
			return
		if event.keycode == KEY_CTRL or event.keycode == KEY_META or event.keycode == KEY_ALT:
			return
		if event.ctrl_pressed or event.meta_pressed or event.alt_pressed:
			return
		if (
			(deny_list.contains(char(uni)) and not allow_list) or
			(not deny_list.contains(char(uni)) and allow_list)
		):
			accept_event()
			return
		if capitalize and (ord("a") <= uni and uni <= ord("z")):
			event.unicode -= 32
		if replace_list.has(char(uni)):
			event.unicode = ord(replace_list[char(uni)])
			return
