extends Container
class_name CallsignEntry

@onready var ID: Identicon = $HBoxContainer/Identicon
@onready var Nam: Label = $HBoxContainer/Label

var CS: int = 0

func _ready():
		ID.Num = CS
		Nam.self_modulate = Main.GetCallsignColor(CS)
		Nam.text = Main.base10ToCallsign(CS)
