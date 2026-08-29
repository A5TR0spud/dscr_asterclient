extends Control
class_name TranslatableMulti
@export var messages: Dictionary[StringName, Array] = {}
## List of properties to format
@export var format: Array[StringName] = []

func _ready():
	Main.instance.reload_dict.connect(refresh)
	refresh()

func refresh():
	for m in messages.keys():
		set(m, DictionaryHandler.signals_to_words(messages[m], m in format))
