extends Container
class_name CallsignEntry

@onready var identicon_node: Identicon = $HBoxContainer/Identicon
@onready var name_node: Label = $HBoxContainer/Label

var callsign: int = 0

func _ready():
		identicon_node.num = callsign
		name_node.self_modulate = Main.get_callsign_color(callsign)
		name_node.text = Main.base_10_to_callsign(callsign)
