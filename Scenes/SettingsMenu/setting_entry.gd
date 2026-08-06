extends VBoxContainer
class_name SettingEntry

@export var Description: Array[int] = []
@export var State: bool:
	get:
		return BButton.IsOn
	set(value):
		BButton.IsOn = value

@onready var DescL: Label = $Description
@onready var Eq: Label = $BoolOption/Equals
@onready var BButton: BoolButton = $BoolOption/BoolButton

func _ready():
	Main.instance.ReloadDict.connect(Refresh)
	BButton.IsOn = State
	Refresh()

func Refresh():
	var o: Array[int] = Description.duplicate()
	o.insert(0, -26)
	o.insert(1, -14)
	o.append(-15)
	DescL.text = DictionaryHandler.Signals2Words(o)
	Eq.text = DictionaryHandler.GetOrDefaultSignalName(-4)

func _on_bool_button_toggled(_toggled_on):
	emit_signal("Set", State)

signal Set(new_value: bool)
