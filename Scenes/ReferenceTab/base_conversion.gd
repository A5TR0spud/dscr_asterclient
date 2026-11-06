extends FoldableContainer

@onready var bin: FilteredLineEdit = $GridContainer/Binary
@onready var tern: FilteredLineEdit = $GridContainer/Ternary
@onready var quatern: FilteredLineEdit = $GridContainer/Quaternary
@onready var sept: FilteredLineEdit = $GridContainer/Sept
@onready var oct: FilteredLineEdit = $GridContainer/Octal
@onready var dec: FilteredLineEdit = $GridContainer/Decimal
@onready var dodec: FilteredLineEdit = $GridContainer/Dodecimal
@onready var hex: FilteredLineEdit = $GridContainer/Hexadecimal

@onready var custradix: SpinBox = $GridContainer/CustomBaseRadix
@onready var custval: FilteredLineEdit = $GridContainer/CustomBaseValue

@onready var custradix2: SpinBox = $GridContainer/CustomBaseRadix2
@onready var custval2: FilteredLineEdit = $GridContainer/CustomBaseValue2

func _on_binary_text_submitted(new_text: String):
	_verify_form(bin)
	dec.text = base_convert(new_text, 2, 10)
	tern.text = base_convert(new_text, 2, 3)
	quatern.text = base_convert(new_text, 2, 4)
	sept.text = base_convert(new_text, 2, 7)
	oct.text = base_convert(new_text, 2, 8)
	dodec.text = base_convert(new_text, 2, 12)
	hex.text = base_convert(new_text, 2, 16)
	custval.text = base_convert(new_text, 2, int(custradix.value))
	custval2.text = base_convert(new_text, 2, int(custradix2.value))

func _on_ternary_text_submitted(new_text: String):
	_verify_form(tern)
	bin.text = base_convert(new_text, 3, 2)
	dec.text = base_convert(new_text, 3, 10)
	quatern.text = base_convert(new_text, 3, 4)
	sept.text = base_convert(new_text, 3, 7)
	oct.text = base_convert(new_text, 3, 8)
	dodec.text = base_convert(new_text, 3, 12)
	hex.text = base_convert(new_text, 3, 16)
	custval.text = base_convert(new_text, 3, int(custradix.value))
	custval2.text = base_convert(new_text, 3, int(custradix2.value))

func _on_quaternary_text_submitted(new_text: String):
	_verify_form(quatern)
	bin.text = base_convert(new_text, 4, 2)
	tern.text = base_convert(new_text, 4, 3)
	dec.text = base_convert(new_text, 4, 10)
	sept.text = base_convert(new_text, 4, 7)
	oct.text = base_convert(new_text, 4, 8)
	dodec.text = base_convert(new_text, 4, 12)
	hex.text = base_convert(new_text, 4, 16)
	custval.text = base_convert(new_text, 4, int(custradix.value))
	custval2.text = base_convert(new_text, 4, int(custradix2.value))

func _on_sept_text_submitted(new_text):
	_verify_form(sept)
	bin.text = base_convert(new_text, 7, 2)
	tern.text = base_convert(new_text, 7, 3)
	quatern.text = base_convert(new_text, 7, 4)
	dec.text = base_convert(new_text, 7, 10)
	oct.text = base_convert(new_text, 7, 8)
	dodec.text = base_convert(new_text, 7, 12)
	hex.text = base_convert(new_text, 7, 16)
	custval.text = base_convert(new_text, 7, int(custradix.value))
	custval2.text = base_convert(new_text, 7, int(custradix2.value))

func _on_octal_text_submitted(new_text: String):
	_verify_form(oct)
	bin.text = base_convert(new_text, 8, 2)
	tern.text = base_convert(new_text, 8, 3)
	quatern.text = base_convert(new_text, 8, 4)
	sept.text = base_convert(new_text, 8, 7)
	dec.text = base_convert(new_text, 8, 10)
	dodec.text = base_convert(new_text, 8, 12)
	hex.text = base_convert(new_text, 8, 16)
	custval.text = base_convert(new_text, 8, int(custradix.value))
	custval2.text = base_convert(new_text, 8, int(custradix2.value))

func _on_decimal_text_submitted(new_text: String):
	_verify_form(dec)
	bin.text = base_convert(new_text, 10, 2)
	tern.text = base_convert(new_text, 10, 3)
	quatern.text = base_convert(new_text, 10, 4)
	sept.text = base_convert(new_text, 10, 7)
	oct.text = base_convert(new_text, 10, 8)
	dodec.text = base_convert(new_text, 10, 12)
	hex.text = base_convert(new_text, 10, 16)
	custval.text = base_convert(new_text, 10, int(custradix.value))
	custval2.text = base_convert(new_text, 10, int(custradix2.value))

func _on_dodecimal_text_submitted(new_text: String):
	_verify_form(dodec)
	bin.text = base_convert(new_text, 12, 2)
	tern.text = base_convert(new_text, 12, 3)
	quatern.text = base_convert(new_text, 12, 4)
	sept.text = base_convert(new_text, 12, 7)
	oct.text = base_convert(new_text, 12, 8)
	dec.text = base_convert(new_text, 12, 10)
	hex.text = base_convert(new_text, 12, 16)
	custval.text = base_convert(new_text, 12, int(custradix.value))
	custval2.text = base_convert(new_text, 12, int(custradix2.value))

func _on_hexadecimal_text_submitted(new_text: String):
	_verify_form(hex)
	bin.text = base_convert(new_text, 16, 2)
	tern.text = base_convert(new_text, 16, 3)
	quatern.text = base_convert(new_text, 16, 4)
	sept.text = base_convert(new_text, 16, 7)
	oct.text = base_convert(new_text, 16, 8)
	dodec.text = base_convert(new_text, 16, 12)
	dec.text = base_convert(new_text, 16, 10)
	custval.text = base_convert(new_text, 16, int(custradix.value))
	custval2.text = base_convert(new_text, 16, int(custradix2.value))

func _on_custom_base_value_text_submitted(new_text):
	var r: int = int(custradix.value)
	cust_r = r
	_verify_form(custval, r)
	new_text = custval.text
	bin.text = base_convert(new_text, r, 2)
	tern.text = base_convert(new_text, r, 3)
	quatern.text = base_convert(new_text, r, 4)
	sept.text = base_convert(new_text, r, 7)
	oct.text = base_convert(new_text, r, 8)
	dodec.text = base_convert(new_text, r, 12)
	dec.text = base_convert(new_text, r, 10)
	hex.text = base_convert(new_text, r, 16)
	custval2.text = base_convert(new_text, r, int(custradix2.value))

var cust_r: int = 5
func _on_custom_base_radix_value_changed(value: int):
	var tmp: String = base_convert(custval.text, cust_r, value)
	custval.max_length = floori(log(INT64_MAX) / log(value))
	custval.text = tmp
	_verify_form(custval, value)
	cust_r = value

func _on_custom_base_value_2_text_submitted(new_text):
	var r: int = int(custradix2.value)
	cust_r2 = r
	_verify_form(custval2, r)
	new_text = custval2.text
	bin.text = base_convert(new_text, r, 2)
	tern.text = base_convert(new_text, r, 3)
	quatern.text = base_convert(new_text, r, 4)
	sept.text = base_convert(new_text, r, 7)
	oct.text = base_convert(new_text, r, 8)
	dodec.text = base_convert(new_text, r, 12)
	dec.text = base_convert(new_text, r, 10)
	hex.text = base_convert(new_text, r, 16)
	custval.text = base_convert(new_text, r, int(custradix.value))

var cust_r2: int = 6
func _on_custom_base_radix_2_value_changed(value):
	var tmp: String = base_convert(custval2.text, cust_r2, value)
	custval2.max_length = floori(log(INT64_MAX) / log(value))
	custval2.text = tmp
	_verify_form(custval2, value)
	cust_r2 = value

func base_convert(val: String, frombase: int, tobase: int) -> String:
	if not val:
		val = "0"
	var comma: bool = val.contains(",")
	if comma:
		val = val.replace_char(ord(","), ord("."))
	var tmp = ""
	var dotted: bool = false
	for c: String in val:
		if c == ".":
			if dotted:
				continue
			dotted = true
		tmp += c
	val = tmp
	if frombase == tobase:
		if comma:
			val = val.replace_char(ord("."), ord(","))
		return val
	
	tmp = val.split(".")
	var intpart: String = (tmp[0] as String).reverse()
	var fracpart: String = tmp[1] if tmp.size() > 1 else ""
	var outint: String = ""
	var outfrac: String = ""
	tmp = 0
	var power: int = 0
	for c: String in intpart:
		tmp += digit_to_number(c) * (frombase ** power)
		power += 1
	
	power = 0
	while tmp > 0:
		var q: int = tmp / tobase
		var r: int = tmp % tobase
		outint += number_to_digit(r)
		tmp = q
	outint = outint.reverse()
	if not outint:
		outint = "0"
	if not dotted or not fracpart:
		return outint
	
	power = 1
	tmp = 0.0
	for c: String in fracpart:
		tmp += digit_to_number(c) / float(frombase ** power)
		power += 1
	
	var tries: int = 0
	@warning_ignore("narrowing_conversion")
	var max_frac_digits: int = log(INT64_MAX) / log(tobase)
	while tmp > 0 and tries < max_frac_digits:
		var q: int = tmp * tobase
		var r: float = float(tmp) * tobase - q
		outfrac += number_to_digit(q)
		tmp = r
		tries += 1
	
	return outint + ("," if comma else ".") + outfrac

func digit_to_number(input: String) -> int:
	var ordo: int = ord(input)
	if ordo >= 48 and ordo <= 57:
		return ordo - 48
	if ordo >= 65 and ordo <= 90:
		return ordo - 55
	return 0

func number_to_digit(input: int) -> String:
	if input <= 9:
		return str(input)
	if input <= 35:
		return char(input + 55)
	#if input <= 9 + 26 + 15:
	#	return char(input - 9 + 21)
	#if input <= 9 + 26 + 15 + 7:
	#	return char(input - 9)
	return ""

func _verify_form(lab: LineEdit, base: int = -1) -> void:
	var input: String = lab.text
	var comma: bool = input.contains(",")
	if comma:
		input = input.replace_char(ord(","), ord("."))
	var dotted: bool = false
	var tmp: String = ""
	for c: String in input:
		if c == ".":
			if dotted:
				continue
			dotted = true
			tmp += "," if comma else "."
			continue
		if base >= 2 and digit_to_number(c) >= base:
			continue
		tmp += c
	if lab.text != tmp:
		lab.text = tmp
