extends VBoxContainer
class_name DictEntry

var _previous_sig: int = INT64_MAX
var sig: int = 0

@onready var signal_label: Label = $Entry/Signal
@onready var meaning_label: RichTextLabel = $Entry/Meaning

func _ready():
	refresh()
	Main.instance.reload_dict.connect(regen_text)

func regen_text():
	meaning_label.text = DictionaryHandler.signals_to_words([sig], false, true, SettingsHandler.do_bbcode, false)

func refresh():
	if _previous_sig == sig:
		return
	signal_label.text = String.num_int64(sig)
	regen_text()
	_previous_sig = sig

func _gui_input(event: InputEvent):
	if event is InputEventMouse:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		DictEditMenu.open(sig, true)
