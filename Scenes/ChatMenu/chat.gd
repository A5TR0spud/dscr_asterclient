extends VBoxContainer
class_name Chat

static var instance: Chat
static var transmission_entry_scene = preload("res://Scenes/ChatMenu/transmission_entry.tscn")
static var status_log_entry_scene = preload("res://Scenes/ChatMenu/status_log_entry.tscn")
static var separator_scene = preload("res://Scenes/Common/dashed_h_separator.tscn")
static var chat_channel_scene = preload("res://Scenes/ChatMenu/chat_channel.tscn")
@onready var channel_container: TabContainer = $TabContainer

const CHANNEL_SELECTOR: int = -65535
const COMMAND_JOIN: int = -65534
const COMMAND_LEAVE: int = -65533
const SKELETON_KEY: int = -65536

func _enter_tree():
	instance = self
	call_deferred("_post_ready")

func _post_ready():
	Main.instance.reload_settings.connect(open_loaded_channels)
	open_loaded_channels()

func open_loaded_channels():
	for tab_id in range(1, channel_container.get_child_count()):
		(instance.channel_container as TabContainer).set_tab_hidden(tab_id, true)
	for channel_id in SettingsHandler.opened_channels:
		enable_channel(channel_id)

func _gui_input(event: InputEvent):
	if event is InputEventMouse:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		DictEditMenu.instance.hide()

static func on_chat_display_child_entered_tree(node: Node, chat_body: VBoxContainer):
	if node is Separator:
		return
	var idx: int = node.get_index()
	var prev: Node = chat_body.get_child(idx - 1) if idx - 1 >= 0 else null
	var prev2: Node = chat_body.get_child(idx - 2) if idx - 2 >= 0 else null
	var prev_sep: Separator = prev if prev is Separator else null
	var prev_msg: ChatEntry = prev2 if prev2 is ChatEntry else null
	if prev_sep and prev_msg and node is ChatEntry and prev_msg.sender == node.sender:
		prev_sep.queue_free()
	var s = separator_scene.instantiate()
	chat_body.add_child(s)
	chat_body.move_child(s, idx + 1)

static func on_chat_display_child_exiting_tree(node: Node, chat_body: VBoxContainer):
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

static func new_transmission(packet: PackedStringArray) -> void:
	var transmission_number: int = packet[1].to_int()
	var integer_message: Array[int] = []
	for part in packet.slice(2):
		integer_message.append(part.to_int())
		
	var new_message: TransEntry = transmission_entry_scene.instantiate()
	new_message.timestamp = Time.get_ticks_msec()
	new_message.sender = packet[0].to_int()
	new_message.trans = transmission_number
	new_message.message = integer_message
	
	var channel_id = null
	if (len(integer_message) > 2 and integer_message[0] == CHANNEL_SELECTOR):
		channel_id = integer_message[1]
		new_message.message = integer_message.slice(2)
		print(integer_message.slice(2))
	
	
	var channel: Node = get_channel_node(channel_id)
	var child_count: int = channel.get_child_count()
	var idx: int = 0
	var i: int = 0
	# what the [pakala] is this‽‽‽
	# i tried giving it better names, didnt help much
	while idx < child_count and i <= 25:
		var end = channel.get_child(-idx)
		if end is TransEntry:
			if end.trans == transmission_number:
				return
			i += 1
		idx += 1
	
	channel.add_message_node(new_message)

enum State {
	CONNECTING,
	CONNECTED,
	FAILED_TO_CONNECT,
	DISCONNECTING,
	DISCONNECTED,
	WILL_AUTO_RECONNECT_SOON,
	UNKNOWN_WORD,
	INPUT_TOO_LONG,
	INPUT_TOO_SHORT,
	INPUT_LENGTH_INVALID,
	DUPLICATE_NAME,
}

## gets channel node given an id.
## if an id is not provided, the default channel is used
## if a channel does not exist, its scene will be instantiated and set up
static func get_channel_node(id = null) -> Node:
	if id == null:
		return instance.channel_container.get_child(0)
	else:
		if instance.channel_container.has_node(str(id)):
			return instance.channel_container.get_node(str(id))
		else:
			var channel_node = chat_channel_scene.instantiate()
			instance.channel_container.add_child(channel_node)
			var tab_id = channel_node.get_index()
			channel_node.set_channel_name(id)
			
			# TODO: add a setting to enable channels by default when a message is sent
			(instance.channel_container as TabContainer).set_tab_hidden(tab_id, true)
			
			return channel_node

static func get_current_channel_node() -> Node:
	return instance.channel_container.get_child(instance.channel_container.current_tab)

static func enable_channel(id: int):
	var tab_id = get_channel_node(id).get_index()
	(instance.channel_container as TabContainer).set_tab_hidden(tab_id, false)
	if id not in SettingsHandler.opened_channels:
		SettingsHandler.opened_channels.append(id)
		SettingsHandler.save()

static func disable_channel(id: int):
	var tab_id = get_channel_node(id).get_index()
	(instance.channel_container as TabContainer).set_tab_hidden(tab_id, true)
	if id in SettingsHandler.opened_channels:
		SettingsHandler.opened_channels.erase(id)
		SettingsHandler.save()

static func focus_channel(id: int):
	get_channel_node(id).visible = true

func _on_tab_container_tab_changed(tab: int) -> void:
	channel_container.get_child(tab).clear_notification()

static func new_log(state: State, args: Array = []) -> void:
	var new_message: StatusLogEntry = status_log_entry_scene.instantiate()
	new_message.timestamp = Time.get_ticks_msec()
	var msg: Array = []
	match state:
		State.CONNECTING:
			#COMPUTER DOES [ DSCR COMMUNICATE ] WANT DOST
			msg = [-241, -86, -14, -247, -196, -15, -127, -85]
		State.CONNECTED:
			#GOOD ; COMPUTER DOES DSCR COMMUNICATE CAN DOST
			msg = [-154, -2, -241, -86, -247, -196, -145, -85]
		State.FAILED_TO_CONNECT:
			#BAD ; COMPUTER DOES DSCR COMMUNICATE CAN NOT DOST
			msg = [-155, -2, -241, -86, -247, -196, -145, -29, -85]
		State.DISCONNECTING:
			#DSCR AND COMPUTER DOES [ COMMUNICATE ] WANT NOT MUTUAL DOST SMALL NEXT TIME WHEN
			msg = [-247, -30, -241, -86, -14, -196, -15, -127, -29, -186, -85, -109, -120, -65, -121]
		State.DISCONNECTED:
			#DSCR DOES COMPUTER COMMUNICATE NOT DOST
			msg = [-247, -86, -241, -196, -29, -85]
		State.WILL_AUTO_RECONNECT_SOON:
			#COMPUTER DOES [ DSCR COMMUNICATE ] WANT DOST $x ASEC NEXT WHEN
			msg = [-241, -86, -14, -247, -196, -15, -127, -85, int(args[0]), -69, -120, -121]
		State.UNKNOWN_WORD:
			#UNKNOWN SIGNAL IS [ %x, %x, %x, ETC ]
			msg = [-124, -42, -100, -14]
			for idx in range(args.size()):
				if idx > 0:
					msg.append(-3)
				msg.append(str(args[idx]))
			msg.append(-15)
		State.INPUT_TOO_LONG:
			#COMPUTER DOES TRANSMISSION [ SIGNAL COUNT > 2000 ] COMMUNICATE CAN NOT DOST
			msg = [-241, -86, -43, -14, -42, -23, -32, Main.MAX_MESSAGE_LENGTH, -15, -196, -145, -29, -85]
		State.INPUT_TOO_SHORT:
			#COMPUTER DOES TRANSMISSION [ SIGNAL COUNT < 2 ] COMMUNICATE CAN NOT DOST
			msg = [-241, -86, -43, -14, -42, -23, -33, 2, -15, -196, -145, -29, -85]
		State.INPUT_LENGTH_INVALID:
			# one arg -> must be equal
			# two args -> range 
			if len(args) == 1:
				msg = [-241, -86, -43, -14, -42, -23, -4, -29, int(args[0]), -15, -196, -145, -29, -85]
		State.DUPLICATE_NAME:
			#SIGNAL [ - #] AND SIGNAL [ - #] IS SYMMETRIC; "%s"
			msg = [-42, -14, -1, absi(int(args[0])), -15, -30, -42, -14, -1, absi(int(args[1])), -15, -100, -229, -2, args[2]]

	new_message.message = msg
	new_message.sender = -1574
	get_current_channel_node().add_message_node(new_message)
