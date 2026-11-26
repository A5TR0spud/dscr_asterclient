extends VBoxContainer
class_name DictionaryDisplay

static var dict_entry_scene = preload("res://Scenes/DictDisplayMenu/dict_entry.tscn")

var num_search: String = ""
var nam_search: String = ""

func _ready():
	Main.instance.reload_dict.connect(refresh)

func refresh(force_visible: bool = false):
	for idx: int in range(max(self.get_child_count(), DictionaryHandler.word_keys.size())):
		if idx >= DictionaryHandler.word_keys.size():
			self.get_child(idx).queue_free()
			continue
		if idx < self.get_child_count():
			var _ent: DictEntry = self.get_child(idx)
			_ent.sig = DictionaryHandler.word_keys[idx]
			_ent.refresh()
			if force_visible:
				_ent.show()
		else:
			var obj: DictEntry = dict_entry_scene.instantiate()
			obj.sig = DictionaryHandler.word_keys[idx]
			self.add_child(obj)
	in_order = true
	if not force_visible:
		search_children()

var re_search: bool = false

func _on_num_edit_text_changed(new_text: String):
	num_search = new_text
	re_search = true

func _on_sig_edit_text_changed(new_text: String):
	nam_search = new_text
	re_search = true

var ticker: int = 0
func _physics_process(_delta: float) -> void:
	if re_search and ticker >= 2:
		search_children()
		ticker = -1
	ticker += 1

var in_order: bool = false

func search_children() -> void:
	var order: Array = AutocompleteManager.get_autocomplete_options(nam_search, DictionaryHandler.word_names)
	
	re_search = false
	
	if order.is_empty():
		if not in_order and nam_search.is_empty():
			refresh(true)
		order = DictionaryHandler.word_names
	
	var re_ordered_children: Array[DictEntry] = []
	re_ordered_children.resize(order.size())
	
	for cidx: int in range(self.get_child_count()):
		var c: DictEntry = self.get_child(cidx)
		var target_position: int = order.find(c.strict_name)
		if target_position < 0 and not nam_search.is_empty():
			c.hide()
			continue
		if target_position != cidx and not nam_search.is_empty():
			re_ordered_children[target_position] = c
			c.visible = c.signal_label.text.contains(num_search) or num_search.is_empty()
			in_order = false
			continue
		c.visible = (nam_search.is_empty() or c.strict_name in order) and (c.signal_label.text.contains(num_search) or num_search.is_empty())
	for cdx: int in range(re_ordered_children.size()):
		if is_instance_valid(re_ordered_children[cdx]):
			self.move_child(re_ordered_children[cdx], cdx)
	
	#for i: int in range(order.size()):
		#var s: String = order[i]
		#for j: int in range(i, self.get_child_count()):
			#var c: DictEntry = self.get_child(j)
			#if (c.meaning_label.text == s or nam_search.is_empty()) and (c.signal_label.text.contains(num_search) or num_search.is_empty()):
				#if j != i:
					# this falsely fires. unknown reason
					#self.move_child(c, i)
					#in_order = false
				#c.show()
				#break
			#else:
				#c.hide()

func _on_dictionary_save_open_pressed():
	SaveSystem.open_save_location()
	SaveSystem.load_all()
