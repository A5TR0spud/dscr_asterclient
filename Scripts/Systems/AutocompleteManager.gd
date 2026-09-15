extends Node
class_name AutocompleteManager

const PUA_OFFSET = 0xe000
const PUA_SIZE = 0x0100 # there is more but we prob dont need it

static var _autocomplete_finder: CodeEdit

## Returns autocomplete options using Godot's own CodeEdit.[br]
## [code]against[/code] should be an array of strings.
## Returned array is populated with strings.
static func get_autocomplete_options(to_check: String, against: Array) -> Array:
	if _autocomplete_finder == null:
		_autocomplete_finder = CodeEdit.new()
		_autocomplete_finder.code_completion_enabled = true
		_autocomplete_finder.delimiter_strings.clear()
	_autocomplete_finder.text = to_check
	_autocomplete_finder.set_caret_column(to_check.length() + 1)
	for word: String in against:
		word = encode_special_chars(word)
		_autocomplete_finder.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, word, word)
	_autocomplete_finder.update_code_completion_options(true)

	var options: Array[Dictionary] = _autocomplete_finder.get_code_completion_options()
	_autocomplete_finder.cancel_code_completion()
	if options.is_empty() and to_check in against:
		return [to_check]
	return options.map(func(a): return a["display_text"])

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

static func get_dl_candidates(written: String, list: Array, get_at_least: int = 1) -> Array[String]:
	var best_candidates: Array[String] = []
	var best_costs: Array[float] = []
	var worst_cost: float = INF
	
	for candidate: String in list:
		var c: float = dl(written.to_upper(), candidate.to_upper())
		if c <= worst_cost or best_costs.size() < get_at_least:
			var idx: int = best_costs.bsearch(c)
			best_costs.insert(idx, c)
			best_candidates.insert(idx, candidate)
			worst_cost = best_costs.back()
			if best_costs.size() > get_at_least and (worst_cost - best_costs[0]) / (written.length() + candidate.length()) > 0.2:
				best_costs.pop_back()
				best_candidates.pop_back()
				worst_cost = best_costs.back() if best_costs.size() > 0 else INF
	
	return best_candidates

const _DL_ADD_COST: 	float = 0.100
const _DL_SUB_COST: 	float = 0.500
const _DL_EDT_COST: 	float = 0.575
const _DL_SWP_COST: 	float = 1.000
const _DL_DE_DUPE_COST:	float = 0.050
const _DL_DUPE_COST: 	float = 0.050
const _DL_APPEND_COST: 	float = 0.015
## Damerau-Levenshtein Distance
## A is the base string and B is the target string
## Returns cost to convert a to b, by operating on a
# Code harvested from wikipedia https://en.wikipedia.org/w/index.php?title=Damerau%E2%80%93Levenshtein_distance&oldid=1369217619#Optimal_string_alignment_distance
static func dl(a: String, b: String) -> float:
	var d: Array[Array] = []
	for i in range(a.length() + 1):
		d.append(range(b.length() + 1))
	for i in range(a.length() + 1):
		d[i][0] = i * _DL_SUB_COST
	for j in range(b.length() + 1):
		d[0][j] = j * _DL_ADD_COST * 0.5
	
	var cost: float = 0
	
	for i in range(1, a.length() + 1, 1):
		for j in range(1, b.length() + 1, 1):
			var u := i-1
			var v := j-1
			if a[u] == b[v]:
				cost = 0
			else:
				cost = 1
			d[i][j] = min(
				d[i-1][j] + _DL_SUB_COST, # deletion
				d[i][j-1] + _DL_ADD_COST, # insertion
				d[i-1][j-1] + _DL_EDT_COST * cost) # substitution
			# transposition
			if i > 1 and j > 1 and a[u] == b[v-1] and a[u-1] == b[v]:
				d[i][j] = min(
					d[i][j],
					d[i-2][j-2] + _DL_SWP_COST * cost
				) 
			# de-duplicating
			if i > 1 and j > 1 and a[u] == a[u-1]:
				d[i][j] = min(
					d[i][j],
					d[i-1][j] + _DL_DE_DUPE_COST
				)
			# duplicating
			if i > 1 and j > 1 and b[v] == b[v-1] and b[v] == a[u] and a[u-1] != b[v]:
				d[i][j] = min(
					d[i][j],
					d[i][j-1] + _DL_DUPE_COST
				)
			# append to end
			if v > a.length():
				d[i][j] = min(
					d[i][j],
					d[i][j-1] + _DL_APPEND_COST
				)
	
	#print("from: ", a, " to: ", b)
	#var s0: String = ""
	#for i in range(b.length()):
		#if i != 0:
			#s0 += "\t\t"
		#s0 += b[i]
	#print("\t\t\t"+s0)
	#for i in range(d.size()):
		#var s: Array[String] = []
		#for j in range(d[i].size()):
			#var s1: String = "[" if j == 0 else ""
			#s.append(s1 + str(d[i][j]).pad_decimals(2))
		#printt(a[i-1] if i > 0 else "", ",\t".join(s) + "]")
	#print("-------------")
	
	return d[a.length()][b.length()]
