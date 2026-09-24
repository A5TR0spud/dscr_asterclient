extends VBoxContainer
class_name DictChangeEntry

@onready var edit: LineEdit = $LineEdit
@onready var supports: OptionButton = $SupportOptions
var dict_name: String = "DICTIONARY-1.save"

func _ready():
	refresh()
	Main.instance.reload_dict.connect(refresh)

func refresh():
	edit.text = dict_name
	supports.visible = dict_name == SaveSystem._current_dictionary_filename
	if DictionaryHandler.support_dscr:
		supports.select(1)
	elif DictionaryHandler.support_m0:
		supports.select(0)
	else:
		supports.select(2)

func _on_load_button_pressed():
	SaveSystem.load_folder_dict(dict_name)

func _on_dupe_button_pressed():
	SaveSystem.dupe_dict(dict_name)
	SourcesMenu.refresh_files()

func _on_delete_button_confirmed():
	if SaveSystem.delete_dict_name(dict_name):
		queue_free()

func _on_line_edit_text_submitted(new_text):
	dict_name = SaveSystem.change_dict_name(dict_name, new_text)
	refresh()

func _on_line_edit_focus_exited():
	refresh()

func _on_support_options_item_selected(index: int):
	DictionaryHandler.support_m0 = index < 2
	DictionaryHandler.support_dscr = index == 1
	SaveSystem.save_dict()
	Main.on_dictionary_support_updated()
