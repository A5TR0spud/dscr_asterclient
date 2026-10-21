extends Resource
class_name History
@export
var first: int = 0
@export
var size: int = 0
@export
var catalog: Array[ChatEntryNode] = []
@export
var none_channel_head: int = -1
@export
var channel_heads: Dictionary[int, int] = {}

const MAX_SUPERCAPACITY: int = 4096

func get_head_idx(channel: Variant) -> int:
	verify_size()
	var ni: int = -1
	if channel == Chat.SKELETON_KEY:
		ni = last_valid()
	elif channel is int:
		ni = channel_heads.get(channel, -1)
	else:
		ni = none_channel_head
	return ni if verify_index(ni) else -1

func get_previous_idx(from_idx: int, skeleton_key: bool = false) -> int:
	if not verify_index(from_idx):
		return -1
	var ni: int = -1
	if skeleton_key:
		ni = posmod(from_idx - 1, MAX_SUPERCAPACITY)
		#print(ni)
	else:
		var from: ChatEntryNode = catalog[from_idx]
		if from == null:
			return -1
		ni = from.earlier_in_channel
	return ni if verify_index(ni) else -1

func verify_index(idx: int) -> bool:
	# nothing is valid
	if size == 0:
		return false
	# out of array bounds
	if idx < 0 or idx >= MAX_SUPERCAPACITY:
		return false
	
	# x x 1 1 1 x x
	# ^ ^
	if idx < first and first <= last_valid():
		return false
	
	# x x 1 1 1 x x
	#           ^ ^
	if idx > last_valid() and first <= last_valid():
		return false
	
	# 1 1 x x x 1 1
	#     ^ ^ ^
	if idx > last_valid() and idx < first:
		return false
	
	return true

func get_at_cyclic_index(idx: int) -> ChatEntryNode:
	idx = posmod(idx, MAX_SUPERCAPACITY)
	if not verify_index(idx):
		return null
	return catalog[idx]

func last_basic() -> int:
	return (first + size) % MAX_SUPERCAPACITY

func last_valid() -> int:
	return posmod(first + size - 1, MAX_SUPERCAPACITY)

func add(sender: int, channel: Variant, trx: int, message: PackedInt64Array) -> void:
	var new_msg: ChatEntryNode = ChatEntryNode.new()
	new_msg.sender = sender
	new_msg.channel = channel if channel is int else 0
	new_msg.has_channel = channel is int
	new_msg.message = message
	new_msg.date_timestamp = Time.get_unix_time_from_system()
	new_msg.trx = trx
	push(new_msg)

func push(new_msg: ChatEntryNode) -> void:
	verify_size()
	verify_room()
	if new_msg.has_channel:
		if get_at_cyclic_index(channel_heads.get(new_msg.channel, -1)):
			get_at_cyclic_index(channel_heads[new_msg.channel]).later_in_channel = last_basic()
		new_msg.earlier_in_channel = channel_heads.get(new_msg.channel, -1)
		channel_heads.set(new_msg.channel, last_basic())
	else:
		if get_at_cyclic_index(none_channel_head):
			get_at_cyclic_index(none_channel_head).later_in_channel = last_basic()
		new_msg.earlier_in_channel = none_channel_head
		none_channel_head = last_basic()
	catalog[last_basic()] = new_msg
	size += 1
	#print("first ", first)
	#print("size ", size)
	#print("last ", last_basic())
	#print("mainhead ", none_channel_head)
	#print("heads ", channel_heads)
	#print("hist ", catalog)

func verify_size() -> void:
	if catalog.size() != MAX_SUPERCAPACITY:
		catalog.clear()
		first = 0
		size = 0
		catalog.resize(MAX_SUPERCAPACITY)
		none_channel_head = -1
		channel_heads.clear()

func verify_room() -> void:
	while size >= MAX_SUPERCAPACITY - 1:
		if not remove_eldest():
			return

func remove_eldest() -> bool:
	if size <= 1:
		return false
	var old_first: ChatEntryNode = catalog[first]
	if not old_first:
		return false
	var next_msg_idx: int = old_first.later_in_channel
	#for key: int in channel_heads.keys():
	#	if channel_heads[key] == first:
	#		channel_heads.erase(key)
	#		break
	if first in channel_heads.values():
		channel_heads.erase(old_first.channel)
	if first == none_channel_head:
		none_channel_head = -1
	if verify_index(next_msg_idx) and catalog[next_msg_idx]:
		catalog[next_msg_idx].earlier_in_channel = -1
	catalog[first] = null
	first = (first + 1) % MAX_SUPERCAPACITY
	size -= 1
	return true
