extends RefCounted
class_name TransmissionParser

const DECIMAL = -10
const GROUP_START = -14
const GROUP_END = -15
const NEGATIVE = -1

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

## Checks that the signal at the current position equals the given value, otherwise sets the fail flag.
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

func is_at_end() -> bool:
	return _pos >= _data.size()

## Gets the value at the current position without advancing the cursor.
func peek(offset: int = 0):
	var i := _pos + offset
	if i < 0 or i >= _data.size(): return null

	return _data[i]

## Loops through a list of items, calling the given function to parse each item.
## Should be called when cursor is at a group start marker.
func read_group_items(item_parser: Callable) -> Array:
	var items: Array = []
	expect(GROUP_START)
	while not _error and not is_at_end() and not check(GROUP_END):
		items.append(item_parser.call(self))
	expect(GROUP_END)
	
	return items

## Reads a floating-point number at the current position.
## Ignores leading zeroes in the integer portion, but preserves them in the fractional portion.
func read_number() -> Variant:
	var negative := try_consume(NEGATIVE)
	while peek() == 0: skip()

	var val_str: String = ""
	while not _error and not is_at_end():
		var i = peek()
		if i == DECIMAL:
			val_str += "."
			skip()
			continue
		elif i >= 0:
			val_str += str(i)
			skip()
		else:
			break

	var value = val_str.to_float()

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
