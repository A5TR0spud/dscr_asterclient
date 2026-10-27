extends PanelContainer

@onready var m0_refs: Control = $Corpus/VBoxContainer/M0Refs
@onready var struct: Control = $Corpus/VBoxContainer

func _ready():
	Main.instance.reload_dictionary_support.connect(refresh_dict_support)
	for c: Node in struct.get_children():
		if c is FoldableContainer:
			c.folded = true

func refresh_dict_support():
	m0_refs.visible = DictionaryHandler.support_m0
