extends HBoxContainer
class_name NumberEdit

@onready var neg: Label = $Negative
@onready var nat: LineEdit = $Natural
@onready var dot: Label = $Decimal
@onready var dec: LineEdit = $Rational

var is_negative: bool = false

signal changed

func _ready():
	verify_form()
	Main.instance.reload_dict.connect(refresh)
	Main.instance.localization_reload.connect(refresh)

func _on_natural_character_rejected(c: String):
	if c == "." or c == "," or c == "d":
		dec.grab_focus()
		dec.select_all()
		changed.emit()
	elif c == "-":
		is_negative = not is_negative
		refresh()
		changed.emit()

func _on_rational_character_rejected(c: String):
	if c == "." or c == "," or c == "a":
		nat.grab_focus()
		nat.select_all()
		changed.emit()
	elif c == "-":
		is_negative = not is_negative
		refresh()
		changed.emit()

func get_big_num() -> BigNumber:
	var o: String = "-" if neg else ""
	var n: String = nat.text
	while n.left(1) == "0":
		n = n.substr(1)
	var d: String = dec.text
	while d.right(1) == "0":
		d = d.substr(0, d.length() - 1)
	var e: int
	if n.length() > 0:
		e = n.length()
	else:
		var count: int = 0
		for c in d:
			if c == "0":
				count += 1
			else:
				break
		e = -count
	if not d: d = "0"
	if not n: n = "0"
	o = (d + n).insert(1, ".")
	return BigNumber.new(o + "e" + str(e))

func from_big_num(val: BigNumber):
	#val.m
	#val.e
	#val.as_int()
	var v: String = String.num(val.as_float())
	is_negative = v.begins_with("-")
	refresh()
	var r: RegEx = RegEx.create_from_string("(\\d*).?(\\d*)")
	var m: RegExMatch = r.search(v)
	nat.text = m.get_string(1)
	dec.text = m.get_string(2)

func refresh():
	neg.custom_minimum_size.x = 0
	neg.text = Localizer.translate("NUMBER_NEGATIVE")
	neg.custom_minimum_size.x = neg.get_minimum_size().x
	if not is_negative:
		neg.text = ""
	dot.text = Localizer.translate("NUMBER_DECIMAL")

func _on_natural_text_submitted(_new_text):
	verify_form()
	changed.emit()

func _on_rational_text_submitted(_new_text):
	verify_form()
	changed.emit()

func verify_form():
	var t0: String = nat.text
	var t1: String = dec.text
	while t0.left(1) == "0":
		t0 = t0.substr(1)
	while t1.right(1) == "0":
		t1 = t1.substr(0, t1.length() - 1)
	if not t0: t0 = "0"
	if not t1: t1 = "0"
	nat.text = t0
	dec.text = t1
