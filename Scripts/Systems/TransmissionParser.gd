extends RefCounted
class_name TransmissionParser

var _data: Array
var _error: bool = false
var _error_pos: int = 0
var _error_msg: String
var _pos: int = 0

func _init(data: Array) -> void:
	_data = data

## Return the signal at the current cursor position and advance the cursor forward.
## If parser is already at the end of data, sets the fail flag and returns null.
func advance() -> Variant:
	if _error: return null
	if is_at_end():
		_fail("unexpected EOF")
		return null

	var v = _data[_pos]
	_pos += 1

	return v

## Returns true if the signal at the current position equals the given value.
func check(value: int) -> bool:
	return peek() == value

## Checks that the signal at the current position equals the given value, on success will advance, otherwise sets the fail flag.
func expect(value: int) -> void:
	if _error: return

	var v = peek()
	if v == null:
		_fail("expected %d, got EOF" % value)
		return
	if v != value:
		_fail("expected %d, got %d" % [value, v])
		return

	_pos += 1

func get_error_message() -> String:
	return _error_msg

func has_error() -> bool:
	return _error

#iff is not a typo
## Returns true iff the parser has no error and is not at its end
func can_continue() -> bool:
	return not _error and _pos < _data.size()

func is_at_end() -> bool:
	return _pos >= _data.size()

## Gets the value at the current position without advancing the cursor.
func peek(offset: int = 0):
	var i := _pos + offset
	if i < 0 or i >= _data.size(): return null

	return _data[i]

## Loops through a list of items, calling the given function to parse each item.
## Should be called when cursor is at a group start marker.
## Provided Callable will be provided the parser as its only argument.
func read_group_items(item_parser: Callable, collapse_arrays: bool = false) -> Array:
	var items: Array = []
	expect(SigDB.GROUP_START)
	while can_continue() and not check(SigDB.GROUP_END):
		var tmp = item_parser.call(self)
		if collapse_arrays and tmp is Array:
			items.append_array(tmp)
		else:
			items.append(tmp)
	if not is_at_end():
		expect(SigDB.GROUP_END)
	
	return items

const SIGNAL_CONSTANTS: Dictionary = {
	-805: 2.71828182846, #e (of euler fame)
	-806: PI, #pi
	-354405: TAU, #tau
	-604002: (sqrt(5.0)+1.0)/2.0, #phi (golden ratio),
	-157428: 0, #epsilon (sqrt(0))
	-329: 0, #epsilon (surreal)
}

var TRANSFORMERS: Dictionary = {
	SigDB.DELIMIT: func(a): return a,
	SigDB.ADD: func(a: PackedFloat64Array):
		if a.size() < 2:
			return a
		a[a.size()-2] += a[a.size()-1]
		a.remove_at(a.size()-1)
		return a,
	SigDB.MULT: func(a: PackedFloat64Array):
		if a.size() < 2:
			return a
		a[a.size()-2] *= a[a.size()-1]
		a.remove_at(a.size()-1)
		return a,
	SigDB.SUB: func(a: PackedFloat64Array):
		if a.size() < 2:
			return a
		a[a.size()-2] -= a[a.size()-1]
		a.remove_at(a.size()-1)
		return a,
	SigDB.DIV: func(a: PackedFloat64Array):
		if a.size() < 2:
			return a
		a[a.size()-2] /= a[a.size()-1]
		a.remove_at(a.size()-1)
		return a,
	SigDB.POW: func(a: PackedFloat64Array):
		if a.size() < 2:
			return a
		a[a.size()-2] **= a[a.size()-1]
		a.remove_at(a.size()-1)
		return a,
	SigDB.LENGTH: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = abs(a[a.size()-1])
		return a,
	SigDB.SIGFIG_ROUND: func(a: PackedFloat64Array):
		if a.size() < 2:
			return a
		a[a.size()-2] = String.num(a.size()-2, int(a.size()-1)).to_float()
		a.remove_at(a.size()-1)
		return a,
	SigDB.ROOT: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		var _n: float = 2
		if a.size() >= 2:
			_n = a[a.size()-1]
			a.remove_at(a.size()-1)
		a[a.size()-1] = pow(a[a.size()-1], 1.0 / _n)
		return a,
	SigDB.NATLOG: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = log(a[a.size()-1])
		return a,
	SigDB.WAVE_SINE: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = sin(a[a.size()-1])
		return a,
	SigDB.COSINE: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = cos(a[a.size()-1])
		return a,
	SigDB.TANGENT: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = tan(a[a.size()-1])
		return a,
	SigDB.FACTORIAL: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		var _a: int = int(a[a.size() - 1])
		var _b: int = 1
		for _i in range(_a):
			_b *= _i + 1
		a[a.size() - 1] = _b
		return a,
	SigDB.DEGREE: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = deg_to_rad(a[a.size()-1])
		return a,
	SigDB.RADIAN: func(a): return a,
	SigDB.LOGARITHM: func(a: PackedFloat64Array):
		if a.size() < 2:
			return a
		a[a.size()-2] = log(a[a.size()-2]) / log(a[a.size()-1])
		a.remove_at(a.size()-1)
		return a,
	SigDB.NORMALIZE: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = sign(a[a.size()-1])
		return a,
	SigDB.WAVE_SAW: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = (fposmod(a[a.size()-1] - PI, TAU) - PI) / PI
		return a,
	SigDB.WAVE_TRI: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = absf(fposmod(a[a.size()-1] - (0.5 * PI), TAU) - PI) * 2.0 / PI - 1.0
		return a,
	SigDB.WAVE_SQUARE: func(a: PackedFloat64Array):
		if a.size() < 1:
			return a
		a[a.size()-1] = sign(sin(a[a.size()-1]))
		return a,
	SigDB.MODULO: func(a: PackedFloat64Array):
		if a.size() < 2:
			return a
		a[a.size()-2] = fposmod(a[a.size()-2], a[a.size()-1])
		a.remove_at(a.size()-1)
		return a
}

func parse_out_number() -> float:
	#print("------")
	var stack: PackedFloat64Array = []
	var do: bool = has_number_or_constant()
	while do:
		#print(stack)
		if peek() is not int:
			break
		var _next: int = peek()
		#print(_next)
		if has_number_or_constant():
			stack.append(read_number_or_constant())
		elif _next in TRANSFORMERS.keys():
			if !DictionaryHandler.contains_signal(_next):
				break
			if _next < -245 and !DictionaryHandler.support_dscr:
				break
			stack = Callable(TRANSFORMERS[advance()]).call(stack)
		else:
			break
		do = has_number_or_constant()
		if not do:
			do = peek() in TRANSFORMERS.keys()
		#	print("preview: ", peek())
	#print(stack)
	var prod: float = 0.0 if stack.is_empty() else 1.0
	for _j in stack:
		prod *= _j
	return prod

func read_number_or_constant() -> float:
	if DictionaryHandler.support_dscr:
		for _sigconst: int in SIGNAL_CONSTANTS.keys():
			if DictionaryHandler.contains_signal(_sigconst) and check(_sigconst):
				advance()
				return SIGNAL_CONSTANTS[_sigconst]
	return read_number()

## Peeks a number at the current position + offset and returns its length in signals.
## Uses the same logic as [code]read_number()[/code].
func number_length(offset: int = 0) -> int:
	var idx: int = offset
	if peek(idx) == SigDB.NEGATIVE:
		idx += 1
	while peek(idx) == 0:
		idx += 1
	while not _error and idx < _data.size():
		var i = peek(idx)
		if i == SigDB.DECIMAL:
			idx += 1
			continue
		elif i >= 0:
			idx += 1
		else:
			break

	return idx - offset

func has_number_or_constant() -> bool:
	return has_number() or peek() in SIGNAL_CONSTANTS.keys()

func has_number() -> bool:
	var p = peek()
	return p != null and (p >= 0 or p == SigDB.NEGATIVE or p == SigDB.DECIMAL)

## Reads a floating-point number at the current position.
## Ignores leading zeroes in the integer portion, but preserves them in the fractional portion.
## Failed parses result in an output of 0.
func read_number() -> float:
	var negative := try_consume(SigDB.NEGATIVE)
	while peek() == 0: skip()

	var val_str: String = ""
	while can_continue():
		var i = peek()
		if i == SigDB.DECIMAL:
			val_str += "."
			skip()
			continue
		elif i >= 0:
			val_str += str(i)
			skip()
		else:
			break

	var value: float = val_str.to_float()

	return -value if negative else value

func restore_state(pos: int, clear_error: bool = false) -> void:
	_pos = mini(pos, _data.size())
	if clear_error: _error = false

func save_state() -> int:
	return _pos

func skip(count: int = 1) -> void:
	_pos = mini(_pos + count, _data.size())

## Advance the cursor to the next occurrence of the given value.
## Returns true if the value was found, false otherwise.
func skip_to(value: int) -> bool:
	if _error or is_at_end(): return false
	if peek() == value: return true

	var loc = _data.find(value, _pos)
	if loc > 0:
		_pos = loc
		return true

	return false

## If the current position contains the given value, advances the cursor and returns true.
## Otherwise, the cursor remains unmoved and returns false.
func try_consume(value: int) -> bool:
	if peek() == value:
		_pos += 1
		return true

	return false

func _fail(message: String) -> void:
	if _error: return

	_error = true
	_error_pos = _pos
	_error_msg = "Parse error at %d: %s" % [_pos, message]
