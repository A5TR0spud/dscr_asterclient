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
## "starts": indices for starts of signals ([PackedInt32Array]) [br]
## "lengths": lengths of signals ([PackedInt32Array]) [br]
## "signals": signal numbers ([PackedInt64Array]) [br]
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

#static var time: int
#static func log_time(strig: String):
	#var _time: int = Time.get_ticks_usec() - time
	#print(strig, " secs: ", _time * 0.000001)
	#time = Time.get_ticks_usec()

static func compile_text(input: String) -> PackedInt64Array:
	#time = Time.get_ticks_usec()
	#print("--------")
	_unknowns.clear()
	_error = ErrorCode.UNCOMPILED
	var group_starts: PackedInt32Array = []
	var group_ends: PackedInt32Array = []
	var group_sigs: Array[PackedInt64Array] = []
	var per_starts: Array[PackedInt32Array] = []
	var per_lengths: Array[PackedInt32Array] = []
	var start: int = -1
	var finished_to_idx: int = 0
	input = input.to_upper()
	#print(input)
	while start + 1 < input.length():
		start += 1
		if is_whitespace(input[start]):
			continue
		#print(start, " : ", input[start])
		if input[start] == "|":
			var _sub: String = input.substr(start)
			var m := RegEx.create_from_string("^\\|(-?[0-9]{1,18})").search(_sub)
			if m:
				var end: int = start + m.get_string().length()
				if end not in group_ends:
					if start in group_ends:
						var found_idx: int = group_ends.find(start)
						group_ends[found_idx] = end
						group_sigs[found_idx].append(m.get_string().to_int())
						per_lengths[found_idx].append(m.get_string().length())
						per_starts[found_idx].append(start)
					else:
						group_starts.append(start)
						group_ends.append(end)
						group_sigs.append([m.get_string().to_int()])
						per_lengths.append([m.get_string().length()])
						per_starts.append([start])
					start = end - 1
			continue
		if input[start] == "0":
			var end: int = start + 1
			if end not in group_ends:
				if start in group_ends:
					var found_idx: int = group_ends.find(start)
					group_ends[found_idx] = end
					group_sigs[found_idx].append(0)
					per_lengths[found_idx].append(1)
					per_starts[found_idx].append(start)
				else:
					group_starts.append(start)
					group_ends.append(end)
					group_sigs.append([0])
					per_lengths.append([1])
					per_starts.append([start])
			continue
		if input[start].is_valid_int():
			var _sub: String = input.substr(start)
			var m := RegEx.create_from_string("^([0-9]{1,18})").search(_sub)
			if m:
				var end: int = start + m.get_string().length()
				if end not in group_ends:
					if start in group_ends:
						var found_idx: int = group_ends.find(start)
						group_ends[found_idx] = end
						group_sigs[found_idx].append(m.get_string().to_int())
						per_lengths[found_idx].append(m.get_string().length())
						per_starts[found_idx].append(start)
					else:
						group_starts.append(start)
						group_ends.append(end)
						group_sigs.append([m.get_string().to_int()])
						per_lengths.append([m.get_string().length()])
						per_starts.append([start])
					start = end - 1
			continue
		
		var extension_idx: PackedInt64Array = []
		var extend_with: PackedInt64Array = []
		var extend_to: PackedInt64Array = []
		var extend_length: PackedInt64Array = []
		var found_indices: Array[PackedInt64Array] = DictionaryHandler.prefix_tree.find_all_matches(input.substr(start))
		for idx in range(found_indices[0].size()):
			var _length: int = found_indices[1][idx]
			var end: int = start + _length
			var _sig: int = found_indices[0][idx]
			var found_idx: int = group_ends.find(start)
			if found_idx >= 0 and end not in group_ends:
				extension_idx.append(found_idx)
				extend_with.append(_sig)
				extend_to.append(end)
				extend_length.append(_length)
			elif end not in group_ends:
				group_starts.append(start)
				group_ends.append(end)
				group_sigs.append([_sig])
				per_lengths.append([_length])
				per_starts.append([start])
		for ext: int in range(extension_idx.size()-1, -1, -1):
			var k: int = extension_idx[ext]
			if ext == 0:
				group_ends[k] = extend_to[ext]
				group_sigs[k].append(extend_with[ext])
				per_lengths[k].append(extend_length[ext])
				per_starts[k].append(start)
			else:
				var v = group_sigs[k].duplicate()
				v.append(extend_with[ext])
				group_starts.append(group_starts[k])
				group_ends.append(extend_to[ext])
				group_sigs.append(v)
				v = per_lengths[k].duplicate()
				v.append(extend_length[ext])
				per_lengths.append(v)
				v = per_starts[k].duplicate()
				v.append(start)
				per_starts.append(v)
		if found_indices[1]:
			start += found_indices[1][0] - 1
		else:
			var low_endx: int = -1
			for i: int in range(finished_to_idx, group_ends.size()):
				var terminus: int = group_ends[i]
				if terminus <= start:
					continue
				if low_endx < 0 or group_ends[i] < group_ends[low_endx]:
					low_endx = i
			if low_endx >= 0:
				finished_to_idx = low_endx
				start = group_ends[finished_to_idx] - 1
	#log_time("populate")
	var to: int = 0
	var from: int = 1
	var unflipped: bool = true
	#print("--")
	#print(group_starts)
	#print(group_ends)
	#print(group_sigs)
	#print(per_starts)
	#print(per_lengths)
	while to < group_starts.size() and from < group_starts.size():
		var _fro: int = from if unflipped else to
		var _to: int = to if unflipped else from
		var started: int = group_starts[_fro]
		var end: int = group_ends[_fro]
		var sig: PackedInt64Array = group_sigs[_fro]
		var c_start: int = group_starts[_to]
		var c_end: int = group_ends[_to]
		var c_sig: PackedInt64Array = group_sigs[_to]
		if (
			(started < c_start and c_end == end)
			or (started == c_start and c_end < end)
			or (
				started == c_start and
				end == c_end and
				sig.size() < c_sig.size()
			)
			or (started < c_start and c_end < end)
		):
			group_starts[_to] = started
			group_ends[_to] = end
			group_sigs[_to] = sig
			per_lengths[_to] = per_lengths[_fro]
			per_starts[_to] = per_starts[_fro]
			group_starts.remove_at(_fro)
			group_ends.remove_at(_fro)
			group_sigs.remove_at(_fro)
			per_lengths.remove_at(_fro)
			per_starts.remove_at(_fro)
			unflipped = true
			continue
		unflipped = not unflipped
		if unflipped:
			from += 1
			to += 1
	
	#log_time("filter")
	#print("--")
	#print(group_starts)
	#print(group_ends)
	#print(group_sigs)
	#print(per_starts)
	#print(per_lengths)
	#print("--")
	var prevend: int = 0
	var out: PackedInt64Array = []
	var out_starts: PackedInt32Array = []
	var out_lens: PackedInt32Array = []
	#var mix: Array = []
	for idx: int in range(group_starts.size() + 1):
		var started: int = group_starts[idx] if idx < group_starts.size() else input.length()
		var end: int = group_ends[idx] if idx < group_starts.size() else 0
		if started > prevend:
			var _s: String = input.substr(prevend, started - prevend)
			if !is_whitespace(_s):
				_unknowns.append_array(_s.replace_chars("\n\r\t", ord(" ")).split(" ", false))
				_error = ErrorCode.UNKNOWN
			#if !_s.is_empty():
				#mix.append(_s)
		if idx < group_starts.size():
			out.append_array(group_sigs[idx])
			out_starts.append_array(per_starts[idx])
			out_lens.append_array(per_lengths[idx])
			#mix.append_array(group_sigs[idx])
		prevend = end
	
	#print(out)
	#print(out_starts)
	#print(out_lens)
	#log_time("generate")
	_prev_length = group_starts.size()
	if _prev_length >= Main.MAX_MESSAGE_LENGTH:
		_error = ErrorCode.TOO_LONG
	elif _error == ErrorCode.UNCOMPILED:
		_error = ErrorCode.ALL_GOOD
	_dict_result = {
		"starts": out_starts,
		"lengths": out_lens,
		"signals": out
	}
	return out

static func is_whitespace(val: String) -> bool:
	return val.strip_edges(true, false).is_empty()
