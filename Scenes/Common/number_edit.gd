extends HBoxContainer

@onready var neg: Label = $Negative
@onready var nat: LineEdit = $Natural
@onready var dot: Label = $Decimal
@onready var dec: LineEdit = $Rational

var is_negative: bool = false

func _on_natural_character_rejected(c: String):
	if c == ".":
		dec.grab_focus()
		dec.select_all()
	elif c == "-":
		is_negative = not is_negative

func _on_rational_character_rejected(c: String):
	if c == ".":
		nat.grab_focus()
		nat.select_all()
	elif c == "-":
		is_negative = not is_negative

func refresh():
	neg.text = Localizer.translate("NUMBER_NEGATIVE")
	neg.custom_minimum_size.x = get_minimum_size().x
	if not is_negative:
		neg.text = ""
	dot.text = Localizer.translate("NUMBER_DECIMAL")
