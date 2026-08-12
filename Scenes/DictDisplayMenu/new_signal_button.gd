extends TranslatableSimple

@onready var num_chooser: LineEdit = $"../NewSignalDesig/NumEdit"
@onready var name_chooser: LineEdit = $"../NewSignalDesig/SigEdit"

func _on_pressed() -> void:
	var sig: int = -absi(int(num_chooser.text.to_int()))
	if sig >= 0:
		return
	if name_chooser.text and not DictionaryHandler.contains_signal(sig):
		DictionaryHandler.apply_signal_name(sig, name_chooser.text)
	DictEditMenu.instance.current_signal = sig
	DictEditMenu.instance.show()
	name_chooser.text = ""
	name_chooser.emit_signal("text_changed", "")
	num_chooser.text = ""
	num_chooser.emit_signal("text_changed", "")
