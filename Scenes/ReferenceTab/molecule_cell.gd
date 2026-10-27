extends HBoxContainer

@export var type: String = "ACETIC_ACID"

@onready var struct: Label = $Label
@onready var nomme: Label = $Label2
@onready var notes: Label = $Label3

func _ready():
	var c: LocaleNode = LocaleNode.new()
	c.translations.text = "REF_CMP_FORM_" + type
	struct.add_child(c)
	c = LocaleNode.new()
	c.translations.text = "REF_CMP_NAME_" + type
	nomme.add_child(c)
	c = LocaleNode.new()
	c.translations.text = "REF_CMP_NOTE_" + type
	notes.add_child(c)
