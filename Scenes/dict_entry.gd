extends VBoxContainer
class_name DictEntry

var Sig: int = 0

@onready var SigLabel: Label = $Entry/Signal
@onready var MeaningLabel: Label = $Entry/Meaning

func _ready():
	SigLabel.text = String.num_int64(Sig)
	MeaningLabel.text = DictionaryHandler.GetOrDefaultSignalName(Sig)

func _gui_input(event: InputEvent):
	if event is InputEventMouse:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		if DictEditMenu.instance.CURRENT_SIGNAL == Sig:
			DictEditMenu.instance.visible = not DictEditMenu.instance.visible
			return
		DictEditMenu.instance.CURRENT_SIGNAL = Sig
		DictEditMenu.instance.show()
