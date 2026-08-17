extends VBoxContainer
class_name DictionaryDisplay

static var dict_entry_scene = preload("res://Scenes/DictDisplayMenu/dict_entry.tscn")

var num_search: String = ""
var nam_search: String = ""

func _ready():
	Main.instance.reload_dict.connect(refresh)

func refresh():
	for child in self.get_children():
		child.queue_free()
	for idx in range(DictionaryHandler.desc_keys.size()):
		var instance: DictEntry = dict_entry_scene.instantiate()
		instance.sig = DictionaryHandler.desc_keys[idx]
		add_child(instance)
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
	for child: DictEntry in self.get_children():
		child.visible = (
			(not num_search or str(child.sig).contains(num_search))
			and
			(not nam_search or DictionaryHandler.get_or_default_signal_name(child.sig).contains(nam_search))
		)
	re_search = false

func _on_dictionary_save_open_pressed():
	SoundManager.play_sound(SoundManager.Sounds.CLICK)
	SaveSystem.open_save_location()
	SaveSystem.load()
