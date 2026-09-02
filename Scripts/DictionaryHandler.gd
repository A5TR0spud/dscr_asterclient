class_name DictionaryHandler

# TMFDS DICT.save structure:
#{
#    "wordDict": {
#        "keys": [
#            -1,
#        ],
#        "values": [
#            "-",
#        ]
#    },
#    "descDict": {
#        "keys": [
#            -1,
#        ],
#        "values": [
#            {
#                "desc": "negative sign",
#                "formatMode": 0,
#                "formatModeAfter": 0,
#                "breakOnDouble": false
#            },
#        ]
#    },
#    "id": 1,
#    "beforeUserDefaultMode": 1,
#    "afterUserDefaultMode": 1
#}
# formatting codes:
# 0: no space
# 1: space
# 2: new line
# 3: double new line

const MAX_NAME_LENGTH: int = 20
static var bad_dict: bool = true

static var desc_dict: Dictionary:
	get:
		return SaveSystem.dict.get_or_add("descDict", {
		"keys": [], "values": []
	})
	set(value):
		SaveSystem.dict.set("descDict", value)
static var word_dict: Dictionary:
	get:
		return SaveSystem.dict.get_or_add("wordDict", {
		"keys": [], "values": []
	})
	set(value):
		SaveSystem.dict.set("wordDict", value)
static var desc_keys: Array
static var desc_values: Array:
	get:
		return desc_dict.get_or_add("values", []) as Array[Dictionary]
	set(value):
		desc_dict.set("values", value)
static var word_keys: Array
static var word_names: Array:
	get:
		return word_dict.get_or_add("values", []) as Array[String]
	set(value):
		word_dict.set("values", value)
static var default_before_mode: int:
	get:
		return SaveSystem.dict.get_or_add("beforeUserDefaultMode", int(1))
	set(value):
		SaveSystem.dict.set("beforeUserDefaultMode", int(value))
static var default_after_mode: int:
	get:
		return SaveSystem.dict.get_or_add("afterUserDefaultMode", int(1))
	set(value):
		SaveSystem.dict.set("afterUserDefaultMode", int(value))
static var default_color: String:
	get:
		if SaveSystem.dict.get("defaultColor") is not String:
			SaveSystem.dict.set("defaultColor", "#ffffff")
		return SaveSystem.dict.get_or_add("defaultColor", "#ffffff")
	set(value):
		SaveSystem.dict.set("defaultColor", value)
static var default_bold: bool:
	get:
		return SaveSystem.dict.get_or_add("defaultBold", false)
	set(value):
		SaveSystem.dict.set("defaultBold", value)
static var default_italic: bool:
	get:
		return SaveSystem.dict.get_or_add("defaultItalic", false)
	set(value):
		SaveSystem.dict.set("defaultItalic", value)
static var default_underline: bool:
	get:
		return SaveSystem.dict.get_or_add("defaultUnderline", false)
	set(value):
		SaveSystem.dict.set("defaultUnderline", value)
static var default_strikethrough: bool:
	get:
		return SaveSystem.dict.get_or_add("defaultStrikethrough", false)
	set(value):
		SaveSystem.dict.set("defaultStrikethrough", value)
static var default_background: bool:
	get:
		return SaveSystem.dict.get_or_add("defaultInvert", false)
	set(value):
		SaveSystem.dict.set("defaultInvert", value)

const desc_key: String = "desc"
const before_key: String = "formatMode"
const extra_before_key: String = "extraFormatMode"
const after_key: String = "formatModeAfter"
const extra_after_key: String = "extraFormatModeAfter"
const break_key: String = "breakOnDouble"
const color_key: String = "color"
const bold_key: String = "bold"
const italic_key: String = "italic"
const underline_key: String = "underline"
const strikethrough_key: String = "strikethrough"
const background_key: String = "invert"
const indent_key: String = "indentation"

static func initialize() -> void:
	word_keys = word_dict.get_or_add("keys", []).map(func(v): return int(v)) as Array[int]
	desc_keys = desc_dict.get_or_add("keys", []).map(func(v): return int(v)) as Array[int]

static func export() -> void:
	word_dict.set("keys", word_keys)
	desc_dict.set("keys", desc_keys)

static func sort_dictionary() -> void:
	var tmp = key_sort(word_keys, word_names)
	word_keys = (tmp[0] as Array[int])
	word_names = (tmp[1] as Array[String])
	tmp = key_sort(desc_keys, desc_values)
	desc_keys = (tmp[0] as Array[int])
	desc_values = (tmp[1] as Array[Dictionary])

static func key_sort(keys: Array, vals: Array) -> Array:
	var size: int = keys.size()
	var indices: Array = range(size)
	indices.sort_custom(func(a, b): return int(keys[a]) > int(keys[b]))
	
	var sorted_keys: Array = []
	var sorted_vals: Array = []
	for i in indices:
		sorted_keys.append(keys[i])
		sorted_vals.append(vals[i])

	return [sorted_keys, sorted_vals]

static func apply_signal_name(sig: int, name: String = "", do_logging: bool = false) -> bool:
	sig = -absi(sig)
	name = filter_name_input(name)
	if not name:
		name = "@"+String.num_int64(sig)+"_UNDEF"
	var idx = word_keys.find(sig)
	var dupe_idx: int = word_names.find(name)
	if dupe_idx >= 0 and dupe_idx != idx:
		if do_logging:
			Chat.new_log(Chat.State.DUPLICATE_NAME, [word_keys[dupe_idx], sig, name])
		return false
	if idx >= 0:
		word_names[idx] = name
		return true
	idx = word_keys.bsearch_custom(sig, func(a, b): return a > b)
	word_keys.insert(idx, sig)
	word_names.insert(idx, name)
	return true

static func apply_signal_desc(sig: int, desc: Dictionary) -> void:
	sig = -absi(sig)
	if not desc.has(desc_key):
		desc[desc_key] = "??? ADD NOTES HERE ???"
	if not desc.has(before_key):
		desc[before_key] = default_before_mode
	if not desc.has(after_key):
		desc[after_key] = default_after_mode
	if not desc.has(break_key):
		desc[break_key] = false
	var idx = desc_keys.find(sig)
	if idx >= 0:
		desc_values[idx] = desc
		return
	idx = desc_keys.bsearch_custom(sig, func(a, b): return a > b)
	desc_keys.insert(idx, sig)
	desc_values.insert(idx, desc)
	return

static func get_or_default_signal_name(sig: int) -> String:
	var idx: int = word_keys.find(sig)
	if idx == -1 or word_names.size() <= idx:
		if SettingsHandler.use_at_undef:
			return "@"+String.num_int64(sig)+"_UNDEF"
		return "|"+String.num_int64(sig)
	return word_names[idx]

static func filter_name_input(input: String) -> String:
	input = input.replace_char(ord(" "), ord("_")).remove_chars("|@$")
	input = input.strip_edges().strip_escapes().to_upper()
	var o: String = ""
	for i in range(input.length()):
		var c: String = input[i]
		if c.is_valid_int():
			continue
		o += c
	if o.length() > MAX_NAME_LENGTH:
		o = o.left(MAX_NAME_LENGTH)
	return o

## Checks a string to see if the location at the caret is an invalid signal.
## Returns an array with 2 values:
## 0: The string that failed to parse. Empty if nothing was found at the caret.
## 1: The index the failed string starts at. -1 if successful.
static func find_incomplete_signal(line: String, caret_column: int, expected: String = "") -> Array:
	var delimited: PackedStringArray = line.split(" ")
	var broken_column: int = 0
	for sub in delimited:
		if caret_column <= sub.length():
			if sub.is_empty():
				break
			var result: ParseResult = parse_text(sub)
			if (result.state == ParseResult.FailureState.TOO_LONG
				or result.state == ParseResult.FailureState.UNPARSED
			):
				break
			
			# TODO: make this not suck
			
			if result.state == ParseResult.FailureState.ALL_GOOD:
				if caret_column <= 5:
					return [sub, broken_column]
			
			if result.state == ParseResult.FailureState.UNKNOWN_STRING:
				var start: int = result.stopping_indices[0]
				var prefix: String = sub.left(start)
				if not prefix.is_empty():
					if expected.begins_with(prefix):
						start -= prefix.length()
				var end: int = result.stopping_indices[result.stopping_indices.size() - 1]
				var end_length: int = result.failures[result.stopping_indices.size() - 1].length()
				var length: int = end - start + end_length
				if caret_column < start or caret_column > end + end_length:
					return ["", -1]
				return [sub.substr(start, length), broken_column + start]
		caret_column -= sub.length() + 1
		broken_column += sub.length() + 1
	return ["", -1]

## Takes a string input and outputs a ParseResult object
## The returned object contains information about failure and parsed numerical signals
static func parse_text(input: String, earlyReturn: bool = false) -> ParseResult:
	input = input.strip_edges().strip_escapes().to_upper()
	var result: ParseResult = ParseResult.new()
	result.state = ParseResult.FailureState.ALL_GOOD
	var current_failure: String = ""
	var halting_index: int = 0
	var last_halting_index: int = -1
	while input:
		var cap: int = min(input.length(), MAX_NAME_LENGTH)
		var cut_failure: bool = false
		for i: int in range(cap):
			var subsize: int = cap - i
			var sub: String = input.left(subsize)
			if sub[0] == " ":
				input = input.right(-1)
				halting_index += 1
				cut_failure = true
				break
			if sub[0] == "|":
				var subsub: String = sub.right(-1)
				if not subsub.is_empty() and subsub.is_valid_int():
					result.output.append(subsub.to_int())
					input = input.right(-subsize)
					cut_failure = true
					halting_index += subsize
					break
				if not subsub.is_empty():
					continue
			var found: int = word_names.find(sub)
			if found >= 0:
				result.output.append(word_keys[found])
				input = input.right(-subsize)
				cut_failure = true
				halting_index += subsize
				break
			if (sub[0] == "0"):
				result.output.append(0)
				input = input.right(-1)
				cut_failure = true
				halting_index += 1
				break
			if (sub[0].is_valid_int() and
				sub.is_valid_int() and subsize <= 18
			):
				result.output.append(sub.to_int())
				input = input.right(-subsize)
				cut_failure = true
				halting_index += subsize
				break
			if i == cap - 1:
				current_failure += input[0]
				input = input.right(-1)
				if last_halting_index == -1:
					last_halting_index = halting_index
				last_halting_index = min(halting_index, last_halting_index)
				halting_index += 1
		if (
			not current_failure.is_empty() and
			(cut_failure or current_failure.length() >= MAX_NAME_LENGTH)
		):
			result.failures.append(current_failure)
			result.state = ParseResult.FailureState.UNKNOWN_STRING
			result.stopping_indices.append(last_halting_index)
			last_halting_index = -1
			current_failure = ""
			if earlyReturn:
				return result
		if result.output.size() > Main.MAX_MESSAGE_LENGTH and (earlyReturn or result.output.size() >= 4096):
			result.state = ParseResult.FailureState.TOO_LONG
			return result
	if result.output.size() > Main.MAX_MESSAGE_LENGTH:
		result.state = ParseResult.FailureState.TOO_LONG
		return result
	if not current_failure.is_empty():
		result.failures.append(current_failure)
		result.stopping_indices.append(last_halting_index)
		result.state = ParseResult.FailureState.UNKNOWN_STRING
	return result

static func parse_text_to_signals(input: String, do_logging: bool = true) -> Array[int]:
	var parsed: ParseResult = parse_text(input, not do_logging)
	
	if parsed.state == ParseResult.FailureState.ALL_GOOD:
		return parsed.output
	
	if do_logging:
		match parsed.state:
			ParseResult.FailureState.TOO_LONG:
				Chat.new_log(Chat.State.INPUT_TOO_LONG, [parsed.output.size()])
			ParseResult.FailureState.UNKNOWN_STRING:
				Chat.new_log(Chat.State.UNKNOWN_WORD, parsed.failures)
		
	return []

static func contains_signal(sig: int) -> bool:
	var idx: int = word_keys.find(sig)
	if idx == -1:
		return false
	return word_names.size() > idx

static func get_or_default_signal_desc(sig: int) -> Dictionary:
	var idx: int = desc_keys.find(sig)
	if idx == -1:
		return {
			desc_key: "??? ADD NOTES HERE ???",
			before_key: default_before_mode,
			after_key: default_after_mode,
			break_key: false
		}
	var tmp: Dictionary = desc_values[idx]
	if not tmp.has(desc_key):
		tmp[desc_key] = "??? ADD NOTES HERE ???"
	if not tmp.has(before_key):
		tmp[before_key] = default_before_mode
	tmp[before_key] = int(tmp[before_key])
	if not tmp.has(after_key):
		tmp[after_key] = default_after_mode
	tmp[after_key] = int(tmp[after_key])
	if not tmp.has(break_key):
		tmp[break_key] = false
	return desc_values[idx]

static func calc_luminosity(c: Color) -> float:
	return sqrt(0.299*(c.r*c.r) + 0.587*(c.g*c.g) + 0.114*(c.b*c.b))

static func signals_to_words(input: Array, do_whitespace_format: bool = false, can_do_bbcode: bool = false, do_appearance_format: bool = false, do_clickable: bool = false) -> String:
	var o: String = ""
	var indent: int = 0
	var ws: int = 0
	var prev = 1
	for sig in input:
		var format_mode: int = 0
		var format_mode_after: int = 0 if do_whitespace_format else 1
		var format_indent: int = 0
		var word: String = str(sig)
		var bold: bool = false
		var italic: bool = false
		var underline: bool = false
		var strike: bool = false
		var invert: bool = false
		var color: Color = Color.WHITE
		var is_signal: bool = sig is int and sig < 0
		var is_number: bool = sig is int and sig >= 0
		
		if is_signal:
			word = get_or_default_signal_name(sig)
			var desc: Dictionary = get_or_default_signal_desc(sig)
			if do_whitespace_format:
				format_indent = desc.get(indent_key, 0)
				format_mode = desc[before_key] - desc.get(extra_before_key, 0)
				format_mode_after = desc[after_key] - desc.get(extra_after_key, 0)
				if desc[break_key] and prev == sig:
					format_mode_after = 3
			if sig not in word_keys:
				color = default_color
				bold = default_bold
				italic = default_italic
				underline = default_underline
				strike = default_strikethrough
				invert = default_background
			else:
				bold = desc.get(bold_key, false)
				italic = desc.get(italic_key, false)
				underline = desc.get(underline_key, false)
				strike = desc.get(strikethrough_key, false)
				invert = desc.get(background_key, false)
				var color_value = desc.get(color_key)
				if (color_value is int or color_value is float) and color_value >= 0 and color_value <= 64:
					color = VisualizeNode.calculate_color(color_value)
				elif color_value is String:
					color = Color.from_string(color_value, Color.WHITE)
				else:
					color = Color.WHITE
		elif is_number:
			word = str(sig)
			if prev is int and prev == -54 and sig >= 0 and sig <= 64:
				color = VisualizeNode.calculate_color(sig)
				invert = true
		
		if -format_mode >= ws:
			ws = 0
		else:
			ws = maxi(ws, format_mode)
		if format_indent < 0:
			indent = maxi(0, indent + format_indent)
		
		if ws == 1:
			o += " "
		elif ws == 2 or ws == 3:
			o += "\n".repeat(ws - 1)
			if indent > 0:
				o += "\t".repeat(indent)
		ws = format_mode_after
		if format_indent > 0:
			indent += format_indent
		
		if can_do_bbcode:
			# Avoid formatting issues if users put [ in their signal names
			word = word.replace("[", "[lb]")
			if do_clickable:
				o += "[url=" + str(sig) + "]"
			if do_appearance_format:
				if bold:
					o += "[b]"
				if italic:
					o += "[i]"
				if underline:
					o += "[u]"
				if strike:
					o += "[s]"
				if invert:
					o += "[bgcolor=#" + color.to_html(false) + "][color="+("black" if calc_luminosity(color) > 0.5 else "white") + "]"
				elif color != Color.WHITE:
					o += "[color=#" + color.to_html(false) + "]"
		o += word
		if can_do_bbcode:
			if do_appearance_format:
				if invert:
					o += "[/color][/bgcolor]" 
				elif color != Color.WHITE:
					o += "[/color]"
				if strike:
					o += "[/s]"
				if underline:
					o += "[/u]"
				if italic:
					o += "[/i]"
				if bold:
					o += "[/b]"
			if do_clickable:
				o += "[/url]"
		
		prev = sig
	return o.strip_edges()

static func forget_signal(sig: int) -> void:
	var idx: int = word_keys.find(sig)
	if idx >= 0:
		word_keys.remove_at(idx)
		if idx < word_names.size():
			word_names.remove_at(idx)
	
	idx = desc_keys.find(sig)
	if idx >= 0:
		desc_keys.remove_at(idx)
		if idx < desc_values.size():
			desc_values.remove_at(idx)

	Main.on_dict_reload()
