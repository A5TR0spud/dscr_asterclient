extends SyntaxHighlighter
class_name TransmissionHighlighter

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var input := get_text_edit().get_line(line)
	if input.strip_edges().strip_escapes().is_empty(): return {}
	if !SettingsHandler.do_bbcode: return {}

	var color := Color.WHITE
	var result: Dictionary = {}
	
	TransmissionCompilation.compile_text(input)
	var d := TransmissionCompilation.get_as_data_dict()
	var starts: PackedInt64Array = d["starts"]
	var ends: PackedInt64Array = d["ends"]
	var sigs: Array[PackedInt64Array] = d["signal_groups"]
	var prevend: int = 0
	for idx: int in range(starts.size() + 1):
		var start: int = starts[idx] if idx < starts.size() else input.length()
		var end: int = ends[idx] if idx < starts.size() else 0
		if start > prevend:
			color = _push_color(result, prevend, color, Color.RED)
		var offset: int = 0
		if idx < starts.size():
			for sig: int in sigs[idx]:
				if sig < 0:
					var desc = DictionaryHandler.get_or_default_signal_desc(sig)
					color = _push_color(
						result, start + offset, color, DictionaryHandler.calc_desc_color(desc.get(DictionaryHandler.color_key))
					)
					offset += DictionaryHandler.get_or_default_signal_name(sig).length()
				else:
					color = _push_color(
						result, start + offset, color, Color.WHITE
					)
					offset += str(sig).length()
		prevend = end
	
	return result

static func _is_whitespace(s: String) -> bool:
	return s == " " or s == "\t" or s == "\r" or s == "\n"

static func _push_color(result: Dictionary, pos: int, current: Color, new: Color) -> Color:
	if current != new or pos == 0: result.set(pos, { "color": new })
	return new
