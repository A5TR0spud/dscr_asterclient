extends PanelContainer

@onready var m0_refs: Control = $ScrollContainer/VBoxContainer/M0Refs
@onready var ameter: Control = $ScrollContainer/VBoxContainer/UnitConversion/Length/Akermeter
@onready var lasec: Control = $ScrollContainer/VBoxContainer/UnitConversion/Length/Lightakersecond

func _ready():
	Main.instance.reload_dictionary_support.connect(refresh_dict_support)

func refresh_dict_support():
	m0_refs.visible = DictionaryHandler.support_m0
	ameter.visible = DictionaryHandler.support_m0
	lasec.visible = DictionaryHandler.support_m0
