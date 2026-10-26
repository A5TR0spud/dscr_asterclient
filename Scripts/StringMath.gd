class_name StringMath


static func verify(value: String) -> String:
	var r: RegEx = RegEx.create_from_string("(-?)(\\d*).?(\\d*)")
	var m: RegExMatch = r.search(value)
	var neg: String = m.get_string(1)
	var nat: String = m.get_string(2)
	var dec: String = m.get_string(3)
	while nat.left(1) == "0":
		nat = nat.substr(1)
	while dec.right(1) == "0":
		dec = dec.right(-1)
	if not nat:
		nat = "0"
	if not dec:
		dec = "0"
	return neg + nat + "." + dec

const LOG10: float = log(10)

#static func digit_count(val: int) -> int:
#	return (floori(log(val) / LOG10) + 1) if val > 0 else 0

static func multiply(lh: String, rh: String) -> String:
	var neg: bool = false
	if lh.left(1) == "-":
		neg = true
		lh = lh.substr(1)
	if rh.left(1) == "-":
		neg = not neg
		rh = rh.substr(1)
	
	var nat0: int = lh.split(".")[0].to_int()
	var dec0: int = lh.split(".")[1].to_int()
	var nat1: int = rh.split(".")[0].to_int()
	var dec1: int = rh.split(".")[1].to_int()
	
	#var nat0dig: int = digit_count(nat0)
	var dec0dig: int = lh.split(".")[1].length() if dec0 > 0 else 0
	#var nat1dig: int = digit_count(nat1)
	var dec1dig: int = rh.split(".")[1].length() if dec1 > 0 else 0
	
	var whole_prod: int = nat0 * nat1
	var frac_prod0: int = nat0 * dec1
	var frac_prod1: int = nat1 * dec0
	var decim_prod: int = dec0 * dec1
	
	nat0 *= 10 ** (dec0dig + dec1dig)
	frac_prod0 *= 10 ** dec0dig
	frac_prod1 *= 10 ** dec1dig
	var oi: int = whole_prod + frac_prod0 + frac_prod1 + decim_prod
	var o: String = String.num_uint64(oi)
	o.insert(dec0dig + dec1dig, ".")
	if neg:
		o = "-" + o
	return verify(o)

static func divide(num: String, den: String) -> String:
	var neg: bool = false
	if num.left(1) == "-":
		neg = true
		num = num.substr(1)
	if den.left(1) == "-":
		neg = not neg
		den = den.substr(1)
	
	var nat0: String = num.split(".")[0]
	var dec0: String = num.split(".")[1]
	var nat1: String = den.split(".")[0]
	var dec1: String = den.split(".")[1]
	
	num = nat0 + dec0
	den = nat1 + dec1
	var o: String = ""
	
	
	return ""
