extends Container
class_name CallsignEntry

@onready var ID: ColorRect = $HBoxContainer/Identicon
@onready var Nam: Label = $HBoxContainer/Label

var CS: int = 0

func _ready():
		ID.color = Main.GetCallsignColor(CS)
		ID.material.set_shader_parameter("Value", CS)
		Nam.self_modulate = Main.GetCallsignColor(CS)
		Nam.text = Main.base10ToCallsign(CS)
