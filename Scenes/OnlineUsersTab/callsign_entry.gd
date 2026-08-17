extends Container
class_name CallsignEntry

@onready var identicon_node: Identicon = $HBoxContainer/Identicon
@onready var num_node: Label = $HBoxContainer/Number
@onready var name_node: LineEdit = $HBoxContainer/Nickname

var callsign: int = 0

func _ready():
	identicon_node.num = callsign
	num_node.self_modulate = Main.get_callsign_color(callsign)
	name_node.self_modulate = Main.get_callsign_color(callsign)
	Main.instance.reload_nicknames.connect(refresh_name)
	Main.instance.reload_dict.connect(refresh_label)
	refresh_label()
	refresh_name()

func refresh_label():
	num_node.text = Main.base_10_to_callsign(callsign) + " " + DictionaryHandler.get_or_default_signal_name(-100)

func refresh_name():
	name_node.text = NicknamesHandler.get_nick(callsign)

func _on_nickname_editing_toggled(toggled_on):
	if not toggled_on:
		refresh_name()

func _on_nickname_text_submitted(new_text):
	NicknamesHandler.set_nick(callsign, new_text)
