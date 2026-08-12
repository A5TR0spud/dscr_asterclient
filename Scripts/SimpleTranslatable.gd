extends Control
class_name TranslatableSimple
@export var message: Array[int] = []
@export var format: bool = false
@export var property_name: StringName = "text"

func _ready():
	Main.instance.reload_dict.connect(refresh)
	refresh()

func refresh():
	set(property_name, DictionaryHandler.signals_to_words(message, format))
