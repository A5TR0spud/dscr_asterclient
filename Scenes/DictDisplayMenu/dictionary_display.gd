extends VBoxContainer
class_name DictionaryDisplay

static var dict_entry_scene = preload("res://Scenes/DictDisplayMenu/dict_entry.tscn")

var num_search: String = ""
var nam_search: String = ""

func _ready():
	Main.instance.reload_dict.connect(refresh)

func refresh():
	for idx: int in range(max(self.get_child_count(), DictionaryHandler.word_keys.size())):
		if idx >= DictionaryHandler.word_keys.size():
			self.get_child(idx).queue_free()
			continue
		if idx < self.get_child_count():
			self.get_child(idx).sig = DictionaryHandler.word_keys[idx]
			self.get_child(idx).refresh()
		else:
			var obj: DictEntry = dict_entry_scene.instantiate()
			obj.sig = DictionaryHandler.word_keys[idx]
			self.add_child(obj)
	search_children()

var re_search: bool = false

func _on_num_edit_text_changed(new_text: String):
	num_search = new_text
	re_search = true

func _on_sig_edit_text_changed(new_text: String):
	nam_search = DictionaryHandler.filter_name_input(new_text)
	re_search = true

var ticker: int = 0
func _physics_process(_delta: float) -> void:
	if re_search and ticker >= 4:
		search_children()
		ticker = -1
	ticker += 1

func search_children() -> void:
	var options: Array = AutocompleteManager.get_autocomplete_options(nam_search, DictionaryHandler.word_names)
	for child: DictEntry in self.get_children():
		child.visible = (
			(not num_search or str(child.sig).contains(num_search))
			and
			(not nam_search or DictionaryHandler.get_or_default_signal_name(child.sig) in options)
		)
	re_search = false

func _on_dictionary_save_open_pressed():
	SaveSystem.open_save_location()
	SaveSystem.load_all()
