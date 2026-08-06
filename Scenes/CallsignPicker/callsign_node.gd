extends HBoxContainer
class_name CallsignSelector
@onready var dig512: Label = $RollerGrid/Digit512
@onready var dig64: Label = $RollerGrid/Digit64
@onready var dig8: Label = $RollerGrid/Digit8
@onready var dig1: Label = $RollerGrid/Digit1
@onready var ID: Identicon  = $RollerGrid/Identicon

@export_range(0, 4095, 1, "prefer_slider") var base10: int = 0:
	set (value):
		if value < 0:
			value += 4096
		base10 = value % 4096
		base10 = clamp(base10, 0, 4095) #be extra sure
		var rem: int = base10
		@warning_ignore("integer_division")
		dig512.text = String.num_int64(floori(rem / 512))
		rem = rem % 512
		@warning_ignore("integer_division")
		dig64.text = String.num_int64(floori(rem / 64))
		rem = rem % 64
		@warning_ignore("integer_division")
		dig8.text = String.num_int64(floori(rem / 8))
		rem = rem % 8
		dig1.text = String.num_int64(rem)
		dig1.label_settings.font_color = Main.GetCallsignColor(base10)
		ID.Num = base10

@export var CALLSIGN: int = 0:
	set(value):
		CALLSIGN = clamp(value, 0, 4095) #be extra sure
		base10 = CALLSIGN

signal CallsignSubmitted(newValue: int)

func _on_digit_512_inc_pressed():
	base10 += 512
func _on_digit_64_inc_pressed():
	base10 += 64
func _on_digit_8_inc_pressed():
	base10 += 8
func _on_digit_1_inc_pressed():
	base10 += 1

func _on_digit_512_dec_pressed():
	base10 -= 512
func _on_digit_64_dec_pressed():
	base10 -= 64
func _on_digit_8_dec_pressed():
	base10 -= 8
func _on_digit_1_dec_pressed():
	base10 -= 1

func _on_submit_button_pressed():
	CALLSIGN = base10
	emit_signal("CallsignSubmitted", CALLSIGN)

func _on_undo_button_pressed():
	base10 = CALLSIGN
