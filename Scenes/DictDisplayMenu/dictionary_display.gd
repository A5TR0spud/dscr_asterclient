extends VBoxContainer
class_name DictionaryDisplay

static var dictEntryScene = preload("res://Scenes/DictDisplayMenu/dict_entry.tscn")

var NumSearch: String = ""
var NamSearch: String = ""

func _ready():
	Main.instance.ReloadDict.connect(refresh)

func refresh():
	for child in self.get_children():
		child.queue_free()
	for idx in range(DictionaryHandler.descKeys.size()):
		var instance: DictEntry = dictEntryScene.instantiate()
		instance.Sig = DictionaryHandler.descKeys[idx]
		add_child(instance)

var ReSearch: bool = false

func _on_num_edit_text_changed(new_text: String):
	NumSearch = new_text
	ReSearch = true

func _on_sig_edit_text_changed(new_text: String):
	NamSearch = DictionaryHandler.FilterNameInput(new_text)
	ReSearch = true

var ticker: int = 0
func _physics_process(_delta: float) -> void:
	if ReSearch and ticker >= 4:
		SearchChildren()
		ticker = -1
	ticker += 1

func SearchChildren() -> void:
	for child: DictEntry in self.get_children():
		child.visible = (
			(not NumSearch or str(child.Sig).contains(NumSearch))
			and
			(not NamSearch or DictionaryHandler.GetOrDefaultSignalName(child.Sig).contains(NamSearch))
		)
	ReSearch = false

func _on_dictionary_save_open_pressed():
	SaveSystem.OpenSaveLocation()
