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
	var starts: PackedInt32Array = d["starts"]
	var lengths: PackedInt32Array = d["lengths"]
	var sigs: PackedInt64Array = d["signals"]
	var prevend: int = 0
	for idx: int in range(starts.size() + 1):
		var start: int = starts[idx] if idx < starts.size() else input.length()
		var end: int = start + lengths[idx] if idx < starts.size() else 0
		if start > prevend:
			color = _push_color(result, prevend, color, Color.RED)
		if idx < starts.size():
			var sig: int = sigs[idx]
			if sig < 0:
				var desc = DictionaryHandler.get_or_default_signal_desc(sig)
				color = _push_color(
					result, start, color, DictionaryHandler.calc_desc_color(desc.get(DictionaryHandler.color_key))
				)
			else:
				color = _push_color(
					result, start, color, Color.WHITE
				)
		prevend = end
	
	return result

static func _is_whitespace(s: String) -> bool:
	return s == " " or s == "\t" or s == "\r" or s == "\n"

static func _push_color(result: Dictionary, pos: int, current: Color, new: Color) -> Color:
	if current != new or pos == 0: result.set(pos, { "color": new })
	return new
