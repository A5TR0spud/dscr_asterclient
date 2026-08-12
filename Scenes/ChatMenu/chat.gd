extends VBoxContainer
class_name Chat

static var instance: Chat
static var trx_scene = preload("res://Scenes/ChatMenu/transmission_entry.tscn")
static var log_scene = preload("res://Scenes/ChatMenu/status_log_entry.tscn")
static var sep_scene = preload("res://Scenes/Common/dashed_h_separator.tscn")
@onready var chat_body: VBoxContainer = $MarginContainer/ScrollContainer/MarginContainer/ChatDisplay

func _enter_tree():
	instance = self

func _gui_input(event: InputEvent):
	if event is InputEventMouse:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		DictEditMenu.instance.hide()

func _on_chat_display_child_entered_tree(node: Node):
	if node is Separator:
		return
	var idx: int = node.get_index()
	var prev: Node = chat_body.get_child(idx - 1) if idx - 1 >= 0 else null
	var prev2: Node = chat_body.get_child(idx - 2) if idx - 2 >= 0 else null
	var prev_sep: Separator = prev if prev is Separator else null
	var prev_msg: ChatEntry = prev2 if prev2 is ChatEntry else null
	if prev_sep and prev_msg and node is ChatEntry and prev_msg.sender == node.sender:
		prev_sep.queue_free()
	var s = sep_scene.instantiate()
	chat_body.add_child(s)
	chat_body.move_child(s, idx + 1)

func _on_chat_display_child_exiting_tree(node: Node):
	if node is Separator:
		return
	var idx: int = node.get_index()
	var prev: Node = chat_body.get_child(idx - 1) if idx - 1 >= 0 else null
	var prev2: Node = chat_body.get_child(idx - 2) if idx - 2 >= 0 else null
	var next: Node = chat_body.get_child(idx + 1) if idx + 1 < chat_body.get_child_count() else null
	var next2: Node = chat_body.get_child(idx + 2) if idx + 2 < chat_body.get_child_count() else null
	var prev_sep: Separator = prev if prev is Separator else null
	var next_sep: Separator = next if next is Separator else null
	var prev_msg: ChatEntry = prev2 if prev2 is ChatEntry else null
	var next_msg: ChatEntry = next2 if next2 is ChatEntry else null
	if prev_sep and next_sep:
		prev_sep.queue_free()
	if next_sep and prev_msg and next_msg and prev_msg.sender == next_msg.sender:
		next_sep.queue_free()
	elif next_sep and idx == 0:
		next_sep.queue_free()

static func new_transmission(incoming: PackedStringArray) -> void:
	var trans_no: int = incoming[1].to_int()
	var cap: int = instance.chat_body.get_child_count()
	var idx: int = 0
	var i: int = 0
	while idx < cap and i <= 25:
		var en = instance.chat_body.get_child(-idx)
		if en is TransEntry:
			if en.trans == trans_no:
				return
			i += 1
		idx += 1
	var new_message: TransEntry = trx_scene.instantiate()
	new_message.timestamp = Time.get_ticks_msec()
	new_message.sender = incoming[0].to_int()
	new_message.trans = trans_no
	var o: Array[int] = []
	for s in incoming.slice(2):
		o.append(s.to_int())
	new_message.message = o
	instance.chat_body.add_child(new_message)

enum State {
	CONNECTING,
	CONNECTED,
	FAILED_TO_CONNECT,
	DISCONNECTING,
	DISCONNECTED,
	WILL_AUTO_RECONNECT_SOON,
	UNKNOWN_WORD,
	INPUT_TOO_LONG
}

static func new_log(st: State, args: Array = []) -> void:
	var new_message: StatusLogEntry = log_scene.instantiate()
	new_message.timestamp = Time.get_ticks_msec()
	var msg: Array = []
	if st == State.CONNECTING:
		#COMPUTER DOES [ DSCR COMMUNICATE ] WANT DOST
		msg = [-241, -86, -14, -247, -196, -15, -127, -85]
	elif st == State.CONNECTED:
		#GOOD ; COMPUTER DOES DSCR COMMUNICATE CAN DOST
		msg = [-154, -2, -241, -86, -247, -196, -145, -85]
	elif st == State.FAILED_TO_CONNECT:
		#BAD ; COMPUTER DOES DSCR COMMUNICATE CAN NOT DOST
		msg = [-155, -2, -241, -86, -247, -196, -145, -29, -85]
	elif st == State.DISCONNECTING:
		#DSCR AND COMPUTER DOES [ COMMUNICATE ] WANT NOT MUTUAL DOST SMALL NEXT TIME WHEN
		msg = [-247, -30, -241, -86, -14, -196, -15, -127, -29, -186, -85, -109, -120, -65, -121]
	elif st == State.DISCONNECTED:
		#DSCR DOES COMPUTER COMMUNICATE NOT DOST
		msg = [-247, -86, -241, -196, -29, -85]
	elif st == State.WILL_AUTO_RECONNECT_SOON:
		#COMPUTER DOES [ DSCR COMMUNICATE ] WANT DOST $x ASEC NEXT WHEN
		msg = [-241, -86, -14, -247, -196, -15, -127, -85, int(args[0]), -69, -120, -121]
	elif st == State.UNKNOWN_WORD:
		#UNKNOWN SIGNAL IS [ %x, %x, %x, ETC ]
		msg = [-124, -42, -100, -14]
		for idx in range(args.size()):
			if idx > 0:
				msg.append(-3)
			msg.append(str(args[idx]))
		msg.append(-15)
	elif st == State.INPUT_TOO_LONG:
		#COMPUTER DOES TRANSMISSION [ SIGNAL COUNT > 2000 ] COMMUNICATE CAN NOT DOST
		msg = [-241, -86, -43, -14, -42, -23, -32, Main.MAX_MESSAGE_LENGTH, -15, -196, -145, -29, -85]
	new_message.message = msg
	new_message.sender = -1574
	instance.chat_body.add_child(new_message)
