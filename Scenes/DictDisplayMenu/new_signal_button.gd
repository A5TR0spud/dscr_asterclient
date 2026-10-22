extends Button

@onready var num_chooser: LineEdit = $"../NewSignalDesig/NumEdit"
@onready var name_chooser: LineEdit = $"../NewSignalDesig/SigEdit"

func _on_pressed() -> void:
	_try_make(name_chooser.text)

func _on_sig_edit_text_submitted(new_text):
	_try_make(new_text)

func _try_make(new_text: String) -> void:
	var sig: int = -absi(int(num_chooser.text.to_int()))
	if sig >= 0:
		return
	var tmp: String = ""
	if new_text and not DictionaryHandler.contains_signal(sig):
		tmp = DictionaryHandler.filter_name_input(new_text)
	DictEditMenu.open(sig, tmp)
