extends LineEdit
class_name FilteredLineEdit

@export var deny_list: String = "@$|0123456789"
@export var allow_list: bool = false
@export var replace_list: Dictionary = {" ": "_"}
@export var capitalize: bool = true
@export var placeholder: Array[int]

func _ready():
	Main.instance.reload_dict.connect(refresh)
	refresh()

func refresh():
	placeholder_text = DictionaryHandler.signals_to_words(placeholder)

func _gui_input(event):
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
