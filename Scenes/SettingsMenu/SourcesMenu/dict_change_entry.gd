extends VBoxContainer
class_name DictChangeEntry

@onready var edit: LineEdit = $LineEdit
var dict_name: String = "DICTIONARY-1.save"

func _ready():
	refresh()

func refresh():
	edit.text = dict_name

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
