extends PanelContainer

@onready var m0_refs: Control = $Corpus/VBoxContainer/M0Refs

func _ready():
	Main.instance.reload_dictionary_support.connect(refresh_dict_support)

func refresh_dict_support():
	m0_refs.visible = DictionaryHandler.support_m0
