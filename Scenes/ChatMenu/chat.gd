extends VBoxContainer
class_name Chat

static var instance: Chat
static var Trx = preload("res://Scenes/ChatMenu/transmission_entry.tscn")
static var Log = preload("res://Scenes/ChatMenu/status_log_entry.tscn")
static var Sep = preload("res://Scenes/Common/dashed_h_separator.tscn")
@onready var ChatBody: VBoxContainer = $MarginContainer/ScrollContainer/MarginContainer/ChatDisplay

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
	var prev: Node = ChatBody.get_child(idx - 1) if idx - 1 >= 0 else null
	var prev2: Node = ChatBody.get_child(idx - 2) if idx - 2 >= 0 else null
	var prevSep: Separator = prev if prev is Separator else null
	var prevMsg: ChatEntry = prev2 if prev2 is ChatEntry else null
	if prevSep and prevMsg and node is ChatEntry and prevMsg.Sender == node.Sender:
		prevSep.queue_free()
	var s = Sep.instantiate()
	ChatBody.add_child(s)
	ChatBody.move_child(s, idx + 1)

func _on_chat_display_child_exiting_tree(node: Node):
	if node is Separator:
		return
	var idx: int = node.get_index()
	var prev: Node = ChatBody.get_child(idx - 1) if idx - 1 >= 0 else null
	var prev2: Node = ChatBody.get_child(idx - 2) if idx - 2 >= 0 else null
	var next: Node = ChatBody.get_child(idx + 1) if idx + 1 < ChatBody.get_child_count() else null
	var next2: Node = ChatBody.get_child(idx + 2) if idx + 2 < ChatBody.get_child_count() else null
	var prevSep: Separator = prev if prev is Separator else null
	var nextSep: Separator = next if next is Separator else null
	var prevMsg: ChatEntry = prev2 if prev2 is ChatEntry else null
	var nextMsg: ChatEntry = next2 if next2 is ChatEntry else null
	if prevSep and nextSep:
		prevSep.queue_free()
	if nextSep and prevMsg and nextMsg and prevMsg.Sender == nextMsg.Sender:
		nextSep.queue_free()
	elif nextSep and idx == 0:
		nextSep.queue_free()

static func NewTransmission(incoming: PackedStringArray) -> void:
	var transNo: int = incoming[1].to_int()
	var cap: int = instance.ChatBody.get_child_count()
	var idx: int = 0
	var i: int = 0
	while idx < cap and i <= 25:
		var en = instance.ChatBody.get_child(-idx)
		if en is TransEntry:
			if en.Trans == transNo:
				return
			i += 1
		idx += 1
	var newMessage: TransEntry = Trx.instantiate()
	newMessage.Timestamp = Time.get_ticks_msec()
	newMessage.Sender = incoming[0].to_int()
	newMessage.Trans = transNo
	var o: Array[int] = []
	for s in incoming.slice(2):
		o.append(s.to_int())
	newMessage.Message = o
	instance.ChatBody.add_child(newMessage)

enum State {
	Connecting,
	Connected,
	FailedToConnect,
	Disconnecting,
	Disconnected,
	WillAutoReconnectSoon,
	UnknownWord,
	InputTooLong
}

static func NewLog(st: State, args: Array = []) -> void:
	var newMessage: StatusLogEntry = Log.instantiate()
	newMessage.Timestamp = Time.get_ticks_msec()
	var msg: Array = []
	if st == State.Connecting:
		#COMPUTER DOES [ DSCR COMMUNICATE ] WANT DOST
		msg = [-241, -86, -14, -247, -196, -15, -127, -85]
	elif st == State.Connected:
		#GOOD ; COMPUTER DOES DSCR COMMUNICATE CAN DOST
		msg = [-154, -2, -241, -86, -247, -196, -145, -85]
	elif st == State.FailedToConnect:
		#BAD ; COMPUTER DOES DSCR COMMUNICATE CAN NOT DOST
		msg = [-155, -2, -241, -86, -247, -196, -145, -29, -85]
	elif st == State.Disconnecting:
		#DSCR AND COMPUTER DOES [ COMMUNICATE ] WANT NOT MUTUAL DOST SMALL NEXT TIME WHEN
		msg = [-247, -30, -241, -86, -14, -196, -15, -127, -29, -186, -85, -109, -120, -65, -121]
	elif st == State.Disconnected:
		#DSCR DOES COMPUTER COMMUNICATE NOT DOST
		msg = [-247, -86, -241, -196, -29, -85]
	elif st == State.WillAutoReconnectSoon:
		#COMPUTER DOES [ DSCR COMMUNICATE ] WANT DOST $x ASEC NEXT WHEN
		msg = [-241, -86, -14, -247, -196, -15, -127, -85, int(args[0]), -69, -120, -121]
	elif st == State.UnknownWord:
		#UNKNOWN SIGNAL IS [ %x, %x, %x, ETC ]
		msg = [-124, -42, -100, -14]
		for idx in range(args.size()):
			if idx > 0:
				msg.append(-3)
			msg.append(str(args[idx]))
		msg.append(-15)
	elif st == State.InputTooLong:
		#COMPUTER DOES TRANSMISSION [ SIGNAL COUNT > 2000 ] COMMUNICATE CAN NOT DOST
		msg = [-241, -86, -43, -14, -42, -23, -32, Main.MaxMessageLength, -15, -196, -145, -29, -85]
	newMessage.Message = msg
	newMessage.Sender = -1574
	instance.ChatBody.add_child(newMessage)
