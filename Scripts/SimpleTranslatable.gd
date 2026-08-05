extends Control
class_name TranslatableSimple
@export var Message: Array[int] = []
@export var Format: bool = false
@export var PropertyName: StringName = "text"

func _ready():
	Main.instance.ReloadDict.connect(Refresh)

func Refresh():
	self.set(PropertyName, DictionaryHandler.Signals2Words(Message, Format))
