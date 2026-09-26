# code harvested from https://www.youtube.com/watch?v=oobqoCJlHA0
extends RefCounted
class_name Trie

class TrieNode:
	extends RefCounted
	var _signal: int
	var _is_terminus: bool
	var _children: Dictionary[int, TrieNode]
	func _init():
		_signal = 0
		_is_terminus = false
		_children = {}

var root: TrieNode

func _init():
	root = TrieNode.new()

func insert(word: String, sig: int):
	word = word.to_upper()
	var cur: TrieNode = root
	for c in word:
		var cdx: int = ord(c)
		if cdx not in cur._children.keys():
			cur._children[cdx] = TrieNode.new()
		cur = cur._children[cdx]
	cur._signal = sig
	cur._is_terminus = true

func check_word(word: String) -> Variant:
	word = word.to_upper()
	var cur: TrieNode = root
	for c in word:
		var cdx: int = ord(c)
		if cdx not in cur._children.keys():
			return false
		cur = cur._children[cdx]
	if not cur._is_terminus:
		return false
	return cur._signal

func check_prefix(prefix: String) -> bool:
	prefix = prefix.to_upper()
	var cur: TrieNode = root
	for c in prefix:
		var cdx: int = ord(c)
		if cdx not in cur._children:
			return false
		cur = cur._children[cdx]
	return true

## Returns an array of 2 arrays.[br]
## Array 0 is a list of signals.[br]
## Array 1 is a list of corresponding lengths.
func find_all_matches(input: String) -> Array[PackedInt64Array]:
	input = input.to_upper()
	var cur: TrieNode = root
	var out_signals: PackedInt64Array = []
	var out_lengths: PackedInt64Array = []
	for idx: int in range(input.length()):
		var cdx: int = input.unicode_at(idx)
		if cdx not in cur._children:
			break
		cur = cur._children[cdx]
		if cur._is_terminus:
			out_signals.append(cur._signal)
			out_lengths.append(idx + 1)
	
	#if out_lengths or out_signals:
	#	print("find all matches")
	#	print(out_signals)
	#	print(out_lengths)
	return [out_signals, out_lengths]

func remove(word: String) -> void:
	word = word.to_upper()
	var cur: TrieNode = root
	var to_prune: Array[TrieNode] = []
	var to_prune_ord: Array[int] = []
	for idx: int in range(word.length()):
		var cdx: int = word.unicode_at(idx)
		if cdx not in cur._children:
			break
		cur = cur._children[cdx]
		to_prune.append(cur)
		to_prune_ord.append(cdx)
		if idx == word.length() - 1:
			cur._is_terminus = false
	while to_prune.size() > 1:
		var c: TrieNode = to_prune.pop_back()
		var cdx: int = to_prune_ord.pop_back()
		var p: TrieNode = to_prune.back()
		if c._children.is_empty() and not c._is_terminus:
			p._children.erase(cdx)
		else:
			break

func clear() -> void:
	root = TrieNode.new()

func populate_from_arrays(words: Array, sigs: Array) -> void:
	for idx: int in range(sigs.size()):
		insert(words[idx], sigs[idx])
