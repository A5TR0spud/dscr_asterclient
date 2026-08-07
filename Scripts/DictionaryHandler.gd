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

static var descDict: Dictionary:
	get:
		return SaveSystem.Dict.get_or_add("descDict", {
		"keys": [], "values": []
	})
	set(value):
		SaveSystem.Dict.set("descDict", value)
static var wordDict: Dictionary:
	get:
		return SaveSystem.Dict.get_or_add("wordDict", {
		"keys": [], "values": []
	})
	set(value):
		SaveSystem.Dict.set("wordDict", value)
static var descKeys: Array
static var descV: Array:
	get:
		return descDict.get_or_add("values", []) as Array[Dictionary]
	set(value):
		descDict.set("values", value)
static var wordKeys: Array
static var wordNames: Array:
	get:
		return wordDict.get_or_add("values", []) as Array[String]
	set(value):
		wordDict.set("values", value)
static var defaultBeforeMode: int:
	get:
		return SaveSystem.Dict.get_or_add("beforeUserDefaultMode", 1)
	set(value):
		SaveSystem.Dict.set("beforeUserDefaultMode", value)
static var defaultAfterMode: int:
	get:
		return SaveSystem.Dict.get_or_add("afterUserDefaultMode", 1)
	set(value):
		SaveSystem.Dict.set("afterUserDefaultMode", value)

const descKey: String = "desc"
const beforeKey: String = "formatMode"
const afterKey: String = "formatModeAfter"
const breakKey: String = "breakOnDouble"

static func Initialize() -> void:
	wordKeys = wordDict.get_or_add("keys", []).map(func(v): return int(v)) as Array[int]
	descKeys = descDict.get_or_add("keys", []).map(func(v): return int(v)) as Array[int]

static func Export() -> void:
	wordDict.set("keys", wordKeys)
	descDict.set("keys", descKeys)

# Hell is real
static func SortDictionary() -> void:
	var tmp = KeySort(wordKeys, wordNames)
	wordKeys = (tmp[0] as Array[int])
	wordNames = (tmp[1] as Array[String])
	tmp = KeySort(descKeys, descV)
	descKeys = (tmp[0] as Array[int])
	descV = (tmp[1] as Array[Dictionary])
static func KeySort(keys: Array, vals: Array) -> Array:
	#just bubble sort, it's easy
	var unsorted: bool = true
	var size: int = keys.size()
	while unsorted:
		unsorted = false
		for idx in range(size - 1):
			var next: int = idx + 1
			if int(keys[idx]) < int(keys[next]):
				var tmp = keys[idx]
				keys[idx] = keys[next]
				keys[next] = tmp
				tmp = vals[idx]
				vals[idx] = vals[next]
				vals[next] = tmp
				unsorted = true
	return [keys, vals]

static func ApplySignalName(sig: int, name: String = "") -> bool:
	sig = -absi(sig)
	name = FilterNameInput(name)
	if not name:
		name = "@"+String.num_int64(sig)+"_UNDEF"
	if wordNames.has(name):
		return false
	var idx = wordKeys.find(sig)
	if idx >= 0:
		wordNames[idx] = name
		return true
	idx = wordKeys.bsearch_custom(sig, func(a, b): return a > b)
	wordKeys.insert(idx, sig)
	wordNames.insert(idx, name)
	return true

static func ApplySignalDesc(sig: int, desc: Dictionary) -> void:
	sig = -absi(sig)
	if not desc.has(descKey):
		desc[descKey] = "??? ADD NOTES HERE ???"
	if not desc.has(beforeKey):
		desc[beforeKey] = defaultBeforeMode
	if not desc.has(afterKey):
		desc[afterKey] = defaultAfterMode
	if not desc.has(breakKey):
		desc[breakKey] = false
	var idx = descKeys.find(sig)
	if idx >= 0:
		descV[idx] = desc
		return
	idx = descKeys.bsearch_custom(sig, func(a, b): return a > b)
	descKeys.insert(idx, sig)
	descV.insert(idx, desc)
	return

static func GetOrDefaultSignalName(sig: int) -> String:
	var idx: int = wordKeys.find(sig)
	if idx == -1 or wordNames.size() <= idx:
		return "@"+String.num_int64(sig)+"_UNDEF"
	return wordNames[idx]

static func FilterNameInput(input: String) -> String:
	input = input.replace_char(32, 95).remove_char(124)
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

static func ParseTextToSignals(input: String, doLogging: bool = true) -> Array[int]:
	input = input.strip_edges().strip_escapes()
	var out: Array[int] = []
	var failed: Array[String] = []
	var currentFailure: String = ""
	while input:
		var cap: int = min(input.length(), MAX_NAME_LENGTH)
		var cutFailure: bool = false
		for i: int in range(cap):
			var idx: int = cap - i - 1
			var sub: String = input.left(idx + 1)
			if sub[0] == " ":
				input = input.right(-1)
				cutFailure = true
				break
			if sub[0] == "|":
				var subsub: String = sub.right(-1)
				if subsub and subsub.is_valid_int():
					out.append(subsub.to_int())
					input = input.right(-idx - 1)
					cutFailure = true
					break
				continue
			var found: int = wordNames.find(sub)
			if found >= 0:
				out.append(wordKeys[found])
				input = input.right(-idx - 1)
				cutFailure = true
				break
			if (sub[0].is_valid_int() and
				sub.is_valid_int()
			):
				out.append(sub.to_int())
				input = input.right(-idx - 1)
				cutFailure = true
				break
			if idx == 0:
				if not doLogging:
					return []
				currentFailure += input[0]
				input = input.right(-1)
		if (
			not currentFailure.is_empty() and
			(cutFailure or currentFailure.length() >= MAX_NAME_LENGTH)
		):
			failed.append(currentFailure)
			currentFailure = ""
		if out.size() > Main.MaxMessageLength:
			if doLogging:
				Chat.NewLog(Chat.State.InputTooLong)
			return []
	if not currentFailure.is_empty():
		failed.append(currentFailure)
	if failed.size() > 0:
		Chat.NewLog(Chat.State.UnknownWord, failed)
		return []
	return out

static func ContainsSignal(sig: int) -> bool:
	var idx: int = wordKeys.find(sig)
	if idx == -1:
		return false
	return wordNames.size() > idx

static func GetOrDefaultSignalDesc(sig: int) -> Dictionary:
	var idx: int = descKeys.find(sig)
	if idx == -1:
		return {
			descKey: "??? ADD NOTES HERE ???",
			beforeKey: defaultBeforeMode,
			afterKey: defaultAfterMode,
			breakKey: false
		}
	var tmp: Dictionary = descV[idx]
	if not tmp.has(descKey):
		tmp[descKey] = "??? ADD NOTES HERE ???"
	if not tmp.has(beforeKey):
		tmp[beforeKey] = defaultBeforeMode
	if not tmp.has(afterKey):
		tmp[afterKey] = defaultAfterMode
	if not tmp.has(breakKey):
		tmp[breakKey] = false
	return descV[idx]

static func Signals2Words(input: Array, format: bool = false) -> String:
	var o: String = ""
	for i in input.size():
		if input[i] is String:
			o += input[i]
			continue
		var prev = input[i - 1] if i > 0 else 1
		if prev is String: prev = 1
		else: prev = prev as int
		var sig: int = str(input[i]).to_int()
		if sig >= 0:
			o += String.num_int64(sig)
			continue
		var name: String = GetOrDefaultSignalName(sig)
		var desc: Dictionary = GetOrDefaultSignalDesc(sig)
		var formatMode: int = desc[beforeKey]
		var formatModeAfter: int = desc[afterKey]
		var brkDouble: bool = desc[breakKey]
		if format and i > 0 and o.right(2) != "\n\n":
			if formatMode == 1 and o.right(1) != " " and o.right(1) != "\n":
				o += " "
			elif formatMode == 2 and o.right(1) != "\n":
				if o.right(1) == " ":
					o = o.left(-1)
				o += "\n"
			elif formatMode == 3:
				if o.right(1) == " ":
					o = o.left(-1)
				o += "\n\n"
		if not format and i > 0 and o.right(1) != " ":
			o += " "
		o += name
		if not format and i < input.size() - 1:
			var next = input[i + 1]
			if next is int and next >= 0:
				o += " "
		if format and i < input.size() - 1:
			if brkDouble and prev == sig:
				o += "\n"
			elif formatModeAfter == 1:
				o += " "
			elif formatModeAfter == 2:
				o += "\n"
			elif formatModeAfter == 3:
				o += "\n\n"
	return o

static func ForgetSignal(sig: int) -> void:
	var idx: int = wordKeys.find(sig)
	if idx >= 0:
		wordKeys.remove_at(idx)
		if idx < wordNames.size():
			wordNames.remove_at(idx)
	
	idx = descKeys.find(sig)
	if idx >= 0:
		descKeys.remove_at(idx)
		if idx < descV.size():
			descV.remove_at(idx)
	
	Main.OnDictReload()
