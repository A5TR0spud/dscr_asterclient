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
	var ni: int = -1
	if channel == Chat.SKELETON_KEY:
		ni = Chat.history.last_valid()
	elif channel is int:
		ni = Chat.history.channel_heads.get(channel, -1)
	else:
		ni = Chat.history.none_channel_head
	return ni if verify_index(ni) else -1

func get_previous_idx(from_idx: int, skeleton_key: bool = false) -> int:
	var from: ChatEntryNode = get_at_cyclic_index(from_idx)
	if from == null:
		return -1
	var ni: int = -1
	if skeleton_key:
		ni = posmod(from_idx - 1, MAX_SUPERCAPACITY)
	else:
		ni = from.earlier_in_channel
	return ni if verify_index(ni) else -1

func verify_index(idx: int) -> bool:
	if idx < 0 or idx >= MAX_SUPERCAPACITY:
		return false
	if idx >= last_basic() and idx >= first:
		return false
	if idx < first and idx >= last_basic():
		return false
	if idx < first and last_basic() >= first:
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
	return last_basic() - 1

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
	if catalog.size() != MAX_SUPERCAPACITY:
		catalog.resize(MAX_SUPERCAPACITY)
		catalog.clear()
		first = 0
		size = 0
	verify_room()
	if new_msg.has_channel:
		if get_at_cyclic_index(channel_heads.get(new_msg.channel, -1)):
			get_at_cyclic_index(channel_heads.get(new_msg.channel, -1)).later_in_channel = last_basic()
		new_msg.earlier_in_channel = channel_heads.get(new_msg.channel, -1)
		channel_heads.set(new_msg.channel, last_basic())
	else:
		if get_at_cyclic_index(none_channel_head):
			get_at_cyclic_index(none_channel_head).later_in_channel = last_basic()
		new_msg.earlier_in_channel = none_channel_head
		none_channel_head = last_basic()
	catalog[last_basic()] = new_msg
	size += 1

func verify_room() -> void:
	while size >= MAX_SUPERCAPACITY - 1:
		if not remove_eldest():
			return

func remove_eldest() -> bool:
	if size == 0:
		return false
	var n: ChatEntryNode = catalog[first]
	if first in channel_heads.values():
		channel_heads.erase(n.channel)
	if first == none_channel_head:
		none_channel_head = -1
	if n.later_in_channel >= 0 and catalog[n.later_in_channel]:
		catalog[n.later_in_channel].earlier_in_channel = -1
	catalog[first].free()
	catalog[first] = null
	first = (first + 1) % MAX_SUPERCAPACITY
	size -= 1
	return true
