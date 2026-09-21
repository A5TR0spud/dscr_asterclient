extends RefCounted
class_name TransmissionCompilation

static var _unknowns: Array = []
static var _error: ErrorCode = ErrorCode.UNCOMPILED
static var _prev_length: int = 0
static var _dict_result: Dictionary = {}

enum ErrorCode {
	UNCOMPILED,
	ALL_GOOD,
	UNKNOWN,
	TOO_LONG
}

## In the form:[br]
## "starts": starts of signal groups ([PackedInt64Array]) [br]
## "ends": ends of signal groups ([PackedInt64Array]) [br]
## "signal_groups": signal numbers ([Array][lb][PackedInt64Array][rb]) [br]
## The same index refers to the same signal group across all arrays
static func get_as_data_dict() -> Dictionary:
	return _dict_result

## Did the most recent [code]compile_text[/code] call result in an error?
static func has_error() -> bool:
	return _error != ErrorCode.ALL_GOOD

## Logs the error of the most recent [code]compile_text[/code] function call to the in-game chat.
static func log_error() -> void:
	match _error:
		ErrorCode.UNCOMPILED or ErrorCode.ALL_GOOD:
			return
		ErrorCode.TOO_LONG:
			Chat.new_log(Chat.State.INPUT_TOO_LONG, [_prev_length])
		ErrorCode.UNKNOWN:
			Chat.new_log(Chat.State.UNKNOWN_WORD, _unknowns)

static var time: int
static func log_time(strig: String):
	var _time: int = Time.get_ticks_usec() - time
	print(strig, " secs: ", _time * 0.000001)
	time = Time.get_ticks_usec()

static func compile_text(input: String) -> PackedInt64Array:
	time = Time.get_ticks_usec()
	_unknowns.clear()
	_error = ErrorCode.UNCOMPILED
	var starts: PackedInt64Array = []
	var ends: PackedInt64Array = []
	var sigs: Array[PackedInt64Array] = []
	var number_cutoff: int = 0
	for start: int in range(input.length()):
		if input[start] == "|":
			var _sub: String = input.substr(start)
			var m := RegEx.create_from_string("^\\|(-?[0-9]{1,18})").search(_sub)
			if m:
				var end: int = start + 1 + m.get_string().length()
				if end not in ends:
					if start in ends:
						var found_idx: int = ends.find(start)
						ends[found_idx] = end
						sigs[found_idx].append(m.get_string().to_int())
					else:
						starts.append(start)
						ends.append(end)
						sigs.append([m.get_string().to_int()])
					number_cutoff = end
			continue
		if input[start] == "0":
			var end: int = start + 1
			if end not in ends:
				if start in ends:
					var found_idx: int = ends.find(start)
					ends[found_idx] = end
					sigs[found_idx].append(0)
				else:
					starts.append(start)
					ends.append(end)
					sigs.append([0])
			continue
		if input[start].is_valid_int():
			if start < number_cutoff:
				continue
			var _sub: String = input.substr(start)
			var m := RegEx.create_from_string("^([0-9]{1,18})").search(_sub)
			if m:
				var end: int = start + m.get_string().length()
				if end not in ends:
					if start in ends:
						var found_idx: int = ends.find(start)
						ends[found_idx] = end
						sigs[found_idx].append(m.get_string().to_int())
					else:
						starts.append(start)
						ends.append(end)
						sigs.append([m.get_string().to_int()])
					number_cutoff = end
			continue
		
		var extension_idx: PackedInt64Array = []
		var extend_with: PackedInt64Array = []
		var extend_to: PackedInt64Array = []
		for idx in range(DictionaryHandler.word_keys.size()):
			var d: String = DictionaryHandler.word_names[idx]
			var dx: int = DictionaryHandler.word_keys[idx]
			var end: int = start + d.length()
			if input.substr(start, d.length()) == d:
				var found_idx: int = ends.find(start)
				if found_idx >= 0 and end not in ends:
					extension_idx.append(found_idx)
					extend_with.append(dx)
					extend_to.append(end)
				elif end not in ends:
					starts.append(start)
					ends.append(end)
					sigs.append([dx])
		for ext: int in range(extension_idx.size()-1, -1, -1):
			var k: int = extension_idx[ext]
			if ext == 0:
				ends[k] = extend_to[ext]
				sigs[k].append(extend_with[ext])
			else:
				var v: PackedInt64Array = sigs[k].duplicate()
				v.append(extend_with[ext])
				starts.append(starts[k])
				ends.append(extend_to[ext])
				sigs.append(v)
	log_time("populate")
	var to: int = 0
	var from: int = 1
	var unflipped: bool = true
	while to < starts.size() and from < starts.size():
		var _fro: int = from if unflipped else to
		var _to: int = to if unflipped else from
		var start: int = starts[_fro]
		var end: int = ends[_fro]
		var sig: PackedInt64Array = sigs[_fro]
		var c_start: int = starts[_to]
		var c_end: int = ends[_to]
		var c_sig: PackedInt64Array = sigs[_to]
		if (
			(start < c_start and c_end == end)
			or (start == c_start and c_end < end)
			or (
				start == c_start and
				end == c_end and
				sig.size() < c_sig.size()
			)
			or (start < c_start and c_end < end)
		):
			starts[_to] = start
			ends[_to] = end
			sigs[_to] = sig
			starts.remove_at(_fro)
			ends.remove_at(_fro)
			sigs.remove_at(_fro)
			continue
		unflipped = not unflipped
		if unflipped:
			from += 1
			to += 1
	
	log_time("filter")
	var prevend: int = 0
	var out: PackedInt64Array = []
	#var mix: Array = []
	for idx: int in range(starts.size() + 1):
		var start: int = starts[idx] if idx < starts.size() else input.length()
		var end: int = ends[idx] if idx < starts.size() else 0
		if start > prevend:
			var _s: String = input.substr(prevend, start - prevend)
			if !is_whitespace(_s):
				_unknowns.append_array(_s.replace_chars("\n\r\t", ord(" ")).split(" ", false))
				_error = ErrorCode.UNKNOWN
			#if !_s.is_empty():
				#mix.append(_s)
		if idx < starts.size():
			out.append_array(sigs[idx])
			#mix.append_array(sigs[idx])
		prevend = end
	
	log_time("generate")
	_prev_length = starts.size()
	if _prev_length >= Main.MAX_MESSAGE_LENGTH:
		_error = ErrorCode.TOO_LONG
	elif _error == ErrorCode.UNCOMPILED:
		_error = ErrorCode.ALL_GOOD
	_dict_result = {
		"starts": starts,
		"ends": ends,
		"signal_groups": sigs
	}
	return out

static func is_whitespace(val: String) -> bool:
	return val.strip_edges(true, false).is_empty()
