extends SyntaxHighlighter
class_name TransmissionHighlighter

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var input := get_text_edit().get_line(line)
	if input.strip_edges().strip_escapes().is_empty(): return {}

	var color := Color.WHITE
	var pos: int = 0
	var result: Dictionary = {}

	while pos < input.length():
		# Skip over whitespace and numbers
		if _is_whitespace(input[pos]) or input[pos].is_valid_int():
			color = _push_color(result, pos, color, Color.WHITE)
			pos += 1
			continue

		var sub_limit := mini(input.length() - pos, DictionaryHandler.MAX_NAME_LENGTH)
		# Since signal names can't have spaces, we can limit our substring to the next space
		# so we don't have to search as much.
		var next_space := input.find(" ", pos)
		if next_space > 0: sub_limit = mini(sub_limit, next_space - pos)

		var found: bool = false
		for sub_len in range(sub_limit, 0, -1):
			var sub := input.substr(pos, sub_len)

			# Handle unknown signal entries
			if sub[0] == "|":
				var subsub := sub.right(-1)
				if subsub.is_valid_int() and subsub.to_int() < 0:
					if SettingsHandler.do_bbcode:
						color = _push_color(result, pos, color, DictionaryHandler.default_color)
					pos += sub_len
					found = true
					break

			# Attempt to find a signal by name.
			var signal_idx := DictionaryHandler.word_names.find(sub)
			if signal_idx >= 0:
				# Skip coloring if disabled in settings.
				if SettingsHandler.do_bbcode:
					var desc = DictionaryHandler.desc_values[signal_idx]
					var word_color := DictionaryHandler.calc_desc_color(desc.get(DictionaryHandler.color_key))
					color = _push_color(result, pos, color, word_color)

				pos += sub_len
				found = true
				break

		# If nothing was found, it is not a valid signal.
		if not found:
			color = _push_color(result, pos, color, Color.RED)
			pos += 1

	return result

static func _is_whitespace(s: String) -> bool:
	return s == " " or s == "\t" or s == "\r" or s == "\n"

static func _push_color(result: Dictionary, pos: int, current: Color, new: Color) -> Color:
	if current != new or pos == 0: result.set(pos, { "color": new })
	return new
