extends TranslatableSimple

@onready var num_chooser: LineEdit = $"../NewSignalDesig/NumEdit"
@onready var name_chooser: LineEdit = $"../NewSignalDesig/SigEdit"

func _on_pressed() -> void:
	_try_make(name_chooser.text)
	SoundManager.play_sound(SoundManager.Sounds.CLICK)

func _on_sig_edit_text_submitted(new_text):
	_try_make(new_text)

func _try_make(new_text: String) -> void:
	var sig: int = -absi(int(num_chooser.text.to_int()))
	if sig >= 0:
		return
	if new_text and not DictionaryHandler.contains_signal(sig):
		DictionaryHandler.apply_signal_name(sig, new_text)
		SaveSystem.save_dict()
	DictEditMenu.open(sig)
