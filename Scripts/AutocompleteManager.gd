extends Node
class_name AutocompleteManager


static func get_candidates(written: String) -> Array[String]:
	if written.is_valid_int():
		return []
	if written.length() > DictionaryHandler.MAX_NAME_LENGTH + 2:
		return []
	var strings: Array[String] = []
	var costs: Array[float] = []
	for sig in DictionaryHandler.word_names:
		var cost: float = _candidate_cost(written, sig)
		if cost > _THRESHOLD:
			continue
		strings.append(sig)
		costs.append(cost)
	
	var size: int = strings.size()
	var indices: Array = range(size)
	indices.sort_custom(func(a, b): return costs[a] < costs[b])
	
	var out: Array[String] = []
	for i in indices:
		out.append(strings[i])
		#if written == "PARA" and costs[i] < 3:
		#	print(strings[i], " : ", costs[i])

	return out

static func _candidate_cost(written: String, candidate: String) -> float:
	written = written.to_upper()
	candidate = candidate.to_upper()
	
	#var length_score_0: int = candidate.length() - written.length()
	#var length_score_1: int = candidate.length()
	#var score_length: float = minf(length_score_0, length_score_1) / maxf(length_score_0, length_score_1)
	
	return _dl(written, candidate)

const _THRESHOLD: float = 4
const _DL_ADD_COST: float = 0.25
const _DL_SUB_COST: float = 2.0
const _DL_EDT_COST: float = 2.0
const _DL_SWP_COST: float = 1.6
## Damerau-Levenshtein Distance
## A is the base string and B is the target string
## Returns cost to convert a to b, by operating on a
# Code harvested from wikipedia https://en.wikipedia.org/w/index.php?title=Damerau%E2%80%93Levenshtein_distance&oldid=1369217619#Optimal_string_alignment_distance
static func _dl(a: String, b: String) -> float:
	var d: Array[Array] = []
	for i in range(a.length() + 1):
		d.append(range(b.length() + 1))
	for i in range(a.length() + 1):
		d[i][0] = i * _DL_SUB_COST
	for j in range(b.length() + 1):
		d[0][j] = j * _DL_ADD_COST
	
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
			if i > 1 and j > 1 and a[u] == b[v-1] and a[u-1] == b[v]:
				d[i][j] = min(
					d[i][j],
					d[i-2][j-2] + _DL_SWP_COST * cost
				)  # transposition
	#if b == "PARABOLA" or b == "GARBAGE" or b == "PART" or b == "PARENT":
	#	print(a, " to ", b)
	#	for i in d:
	#		print(i)
	return d[a.length()][b.length()]
