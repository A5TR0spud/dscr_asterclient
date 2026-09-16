extends Resource
class_name TransmissionCompilation
var _objects: Array[PositionedSignal]
var _size: int
var _seed: String
var _error: CompileError
const MAXIMUM_COMPILE_LENGTH: int = 4096

enum CompileError {
	UNCOMPILED,
	OK,
	WAY_TOO_LONG,
	UNKNOWN
}

func _init(to_compile: String):
	_seed = to_compile
	_error = CompileError.UNCOMPILED
	_objects = []
	_objects.resize(MAXIMUM_COMPILE_LENGTH)
	_size = 0

func set_new_input(to_compile: String):
	_seed = to_compile
	_error = CompileError.UNCOMPILED
	_size = 0

## Gets the array of compiled signals.[br]
## This data may be junk if it has an error. See [code]get_error()[/code]
func get_compiled() -> Array[PositionedSignal]:
	return _objects.slice(0, _size)

func get_error() -> CompileError:
	return _error

func compile() -> void:
	_size = 0
	var source: Dictionary[int, PositionedSignal] = {}
	for idx: int in range(_seed.length()):
		# check dictionary
		for dict_idx in range(DictionaryHandler.word_keys.size()):
			if dict_idx >= DictionaryHandler.word_names.size():
				continue
			var sig: int = DictionaryHandler.word_keys[dict_idx]
			var name: String = DictionaryHandler.word_names[dict_idx]
			if _seed.substr(idx, name.length()).to_upper() == name.to_upper():
				if !source.has(idx + name.length()):
					source.set(idx + name.length(), PositionedSignal.new(
						sig, idx, idx + name.length()
					))
	
	var seed_cursor: int = 0
	var source_cursor: int = 0
	var dest_cursor: int = 0
	for sindex: int in source.keys():
		_objects[dest_cursor] = source[sindex]
	if _error == CompileError.UNCOMPILED:
		_error = CompileError.OK

func log_errors() -> void:
	var errors: Array = _objects.filter(
		func(a: PositionedSignal):
			return a != null and a.result is not int
	).map(
		func(a: PositionedSignal):
			return _seed.substr(a.start, a.end)
	)
	Chat.new_log(Chat.State.UNKNOWN_WORD, errors)

## Negative numbers refer to a signal.[br]
## 0 refers to a number.[br]
## 1 refers to an error, string, or whitespace.[br]
## 2 means the provided index is invalid.
func get_signal_at(index: int) -> int:
	if index < 0 or index >= _seed.length():
		return 2
	for p: PositionedSignal in get_compiled():
		if p.start <= index and index < p.end:
			if p.result is int:
				if p.result >= 0:
					return 0
				return p.result
			return 1
	return 1

class PositionedSignal:
	extends Resource
	var result: Variant
	var start: int
	var end: int
	func _init(sig: Variant, start0: int, end0: int):
		result = sig
		start = start0
		end = end0

static func compile_text(input: String, do_logging: bool = true) -> Array:
	var _i := TransmissionCompilation.new(input)
	_i.compile()
	if do_logging:
		_i.log_errors()
	#if _i.get_error() == CompileError.OK:
	#	return _i.get_successes()
	return []
