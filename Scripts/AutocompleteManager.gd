extends Node
class_name AutocompleteManager

const PUA_OFFSET = 0xe000
const PUA_SIZE = 0x0100 # there is more but we prob dont need it

static func is_special_character(chr: String) -> bool:
	return chr in "!\"#$%&'()*+,-./:;<=>?@[\\]^`{|}~"

static func encode_special_chars(text: String) -> String:
	for i in len(text):
		if is_special_character(text[i]):
			text[i] = char(ord(text[i]) + PUA_OFFSET)
	return text

static func decode_special_chars(text: String) -> String:
	for i in len(text):
		if ord(text[i]) > PUA_OFFSET and ord(text[i]) < PUA_SIZE + PUA_OFFSET:
			text[i] = char(ord(text[i]) - PUA_OFFSET)
	return text
