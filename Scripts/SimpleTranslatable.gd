extends Control
class_name TranslatableSimple
@export var Message: Array[int] = []
@export var Format: bool = false
@export var PropertyName: StringName = "text"

func _ready():
	Main.instance.ReloadDict.connect(Refresh)
	Refresh()

func Refresh():
	set(PropertyName, DictionaryHandler.Signals2Words(Message, Format))
