extends TranslatableSimple

@onready var NumChooser: LineEdit = $"../NewSignalDesig/NumEdit"
@onready var NameChooser: LineEdit = $"../NewSignalDesig/SigEdit"
@onready var Dict: DictionaryDisplay = $"../ScrollContainer/MarginContainer/Dictionary"

func _on_pressed() -> void:
	var sig: int = -absi(int(NumChooser.text.to_int()))
	if sig >= 0:
		return
	if NameChooser.text and not DictionaryHandler.ContainsSignal(sig):
		DictionaryHandler.ApplySignalName(sig, NameChooser.text)
	DictEditMenu.instance.CURRENT_SIGNAL = sig
	DictEditMenu.instance.show()
	NameChooser.text = ""
	NameChooser.emit_signal("text_changed", "")
	NumChooser.text = ""
	NumChooser.emit_signal("text_changed", "")
