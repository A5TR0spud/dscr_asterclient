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


static var number_before_mode: int:
	get:
		return SaveSystem.dict.get_or_add("numberBefore", int(0))
	set(value):
		SaveSystem.dict.set("numberBefore", int(value))
static var number_after_mode: int:
	get:
		return SaveSystem.dict.get_or_add("numberAfter", int(0))
	set(value):
		SaveSystem.dict.set("numberAfter", int(value))
static var number_color: String:
	get:
		if SaveSystem.dict.get("numberColor") is not String:
			SaveSystem.dict.set("numberColor", "#ffffff")
		return SaveSystem.dict.get_or_add("numberColor", "#ffffff")
	set(value):
		SaveSystem.dict.set("numberColor", value)
static var number_bold: bool:
	get:
		return SaveSystem.dict.get_or_add("numberBold", false)
	set(value):
		SaveSystem.dict.set("numberBold", value)
static var number_italic: bool:
	get:
		return SaveSystem.dict.get_or_add("numberItalic", false)
	set(value):
		SaveSystem.dict.set("numberItalic", value)
static var number_underline: bool:
	get:
		return SaveSystem.dict.get_or_add("numberUnderline", false)
	set(value):
		SaveSystem.dict.set("numberUnderline", value)
static var number_strikethrough: bool:
	get:
		return SaveSystem.dict.get_or_add("numberStrikethrough", false)
	set(value):
		SaveSystem.dict.set("numberStrikethrough", value)
static var number_background: bool:
	get:
		return SaveSystem.dict.get_or_add("numberInvert", false)
	set(value):
		SaveSystem.dict.set("numberInvert", value)

static var support_m0: bool:
	get:
		return SaveSystem.dict.get_or_add("supportMeteorite0", true)
	set(value):
		SaveSystem.dict.set("supportMeteorite0", value)
static var support_dscr: bool:
	get:
		return SaveSystem.dict.get_or_add("supportDSCR", false)
	set(value):
		SaveSystem.dict.set("supportDSCR", value)

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

static var prefix_tree: Trie = Trie.new()

static func initialize() -> void:
	word_keys = word_dict.get_or_add("keys", []).map(func(v): return int(v)) as Array[int]
	desc_keys = desc_dict.get_or_add("keys", []).map(func(v): return int(v)) as Array[int]
	prefix_tree.clear()
	prefix_tree.populate_from_arrays(word_names, word_keys)

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
		prefix_tree.remove(word_names[idx])
		prefix_tree.insert(name, sig)
		word_names[idx] = name
		return true
	idx = word_keys.bsearch_custom(sig, func(a, b): return a > b)
	word_keys.insert(idx, sig)
	word_names.insert(idx, name)
	prefix_tree.insert(name, sig)
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
	if sig >= 0:
		return str(sig)
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

static func parse_text_to_signals(input: String, do_logging: bool = true, ignore_errors: bool = false) -> PackedInt64Array:
	var sigs: PackedInt64Array = TransmissionCompilation.compile_text(input)
	if TransmissionCompilation.has_error():
		if do_logging:
			TransmissionCompilation.log_error()
		if not ignore_errors:
			return []
	return sigs

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

static func calc_desc_color(color_value: Variant) -> Color:
	if (color_value is int or color_value is float) and color_value >= 0 and color_value <= 64:
		return VisualizeNode.calculate_color(color_value)
	elif color_value is String:
		return Color.from_string(color_value, Color.WHITE)
	else:
		return Color.WHITE

static func signals_to_words(input: Array, do_whitespace_format: bool = false, can_do_bbcode: bool = false, do_appearance_format: bool = false, do_clickable: bool = false, do_hint: bool = false) -> String:
	var o: String = ""
	var indent: int = 0
	var ws: int = 0
	var prev = 1
	if not SettingsHandler.do_formatting:
		do_whitespace_format = false
	var color_color_numbers: bool = support_m0 and SettingsHandler.color_signal_mode == 1
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
		var hint: String = ""
		
		if is_signal:
			hint = str("|", sig)
			word = get_or_default_signal_name(sig)
			var desc: Dictionary = get_or_default_signal_desc(sig)
			if do_whitespace_format:
				format_indent = desc.get(indent_key, 0)
				format_mode = desc[before_key] - desc.get(extra_before_key, 0)
				format_mode_after = desc[after_key] - desc.get(extra_after_key, 0)
				if prev is int and desc[break_key] and prev == sig:
					format_mode_after = 2
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
				color = calc_desc_color(desc.get(color_key))
		elif is_number:
			word = str(sig)
			if sig != 0:
				hint = str(get_or_default_signal_name(-sig))
			
			if do_whitespace_format:
				format_mode = number_before_mode
				format_mode_after = number_after_mode
			if sig not in word_keys:
				color = number_color
				bold = number_bold
				italic = number_italic
				underline = number_underline
				strike = number_strikethrough
				invert = number_background
			
			if color_color_numbers and prev is int and prev == -54 and sig >= 0 and sig <= 64:
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
		#TODO: [indent]
		#[indent] unfortunately forces a newline
		#it would fix word-wrapping, too. there must be a way to make it work.
		#maybe the indent option itself has to be changed
		if can_do_bbcode:
			# Avoid formatting issues if users put [ in their signal names
			word = word.replace("[", "[lb]")
			if do_clickable and is_signal:
				o += "[url=" + str(sig) + "]"
			if do_hint and hint:
				o += str("[hint=\"", hint ,"\"]")
			if do_appearance_format:
				if bold:
					o += "[b]"
				if italic:
					o += "[i]"
				if strike or underline:
					o += str("[su2 u=", underline, " s=", strike, "]")
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
				if strike or underline:
					o += "[/su2]"
				if italic:
					o += "[/i]"
				if bold:
					o += "[/b]"
			if do_hint and hint:
				o += "[/hint]"
			if do_clickable and is_signal:
				o += "[/url]"
		
		prev = sig
	return o.strip_edges()

static func forget_signal(sig: int, reload: bool = true) -> void:
	var idx: int = word_keys.find(sig)
	if idx >= 0:
		word_keys.remove_at(idx)
		if idx < word_names.size():
			prefix_tree.remove(word_names[idx])
			word_names.remove_at(idx)
	
	idx = desc_keys.find(sig)
	if idx >= 0:
		desc_keys.remove_at(idx)
		if idx < desc_values.size():
			desc_values.remove_at(idx)
	
	if reload:
		Main.on_dict_reload()
