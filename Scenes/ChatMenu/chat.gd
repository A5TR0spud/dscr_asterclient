extends VBoxContainer
class_name Chat

static var instance: Chat
static var transmission_entry_scene = preload("res://Scenes/ChatMenu/transmission_entry.tscn")
static var status_log_entry_scene = preload("res://Scenes/ChatMenu/status_log_entry.tscn")
static var separator_scene = preload("res://Scenes/Common/dashed_h_separator.tscn")
static var chat_channel_scene = preload("res://Scenes/ChatMenu/chat_channel.tscn")
@onready var channel_container: TabContainer = $TabContainer
@onready var message_get_sound: AudioStreamPlayer = $MessageGet

const CHANNEL_SELECTOR: int = -65535
const COMMAND_JOIN: int = -65534
const COMMAND_LEAVE: int = -65533
const SKELETON_KEY: int = -65536

static var ten_most_recent_transmissions: Array[int] = [] as Array[int]

func _enter_tree():
	instance = self

func _ready():
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
	
	# avoid adding duplicate entries if transmission number has already been received recently
	# this is for reconnecting, since the server sends/resends the 10 most recent messages
	if transmission_number in ten_most_recent_transmissions:
		return
	ten_most_recent_transmissions.append(transmission_number)
	if ten_most_recent_transmissions.size() > 10:
		ten_most_recent_transmissions.remove_at(0)
	
	var channel_id = null
	if (len(integer_message) >= 2 and integer_message[0] == CHANNEL_SELECTOR):
		channel_id = integer_message[1]
		integer_message = integer_message.slice(2)
		print(integer_message)
	
	new_message.message = integer_message
	
	var channel: Control = get_channel_node(channel_id)
	
	if (
		(new_message.sender != Main.instance.previously_accepted_callsign)
		and (not channel.visible or not instance.get_window().has_focus())
		and channel_is_visible(channel_id)
	):
		instance.message_get_sound.play()
	
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
	INPUT_ENCRYPT_TOO_SHORT,
	INPUT_COMMAND_LENGTH_INVALID,
	INPUT_LENGTH_INVALID,
	DUPLICATE_NAME,
}

static func channel_is_visible(id = null) -> bool:
	if id == null:
		return true
	var has: bool = instance.channel_container.has_node(str(id))
	if not has:
		return false
	var node = instance.channel_container.get_node(str(id))
	return not (instance.channel_container as TabContainer).is_tab_hidden(node.get_index())

## gets channel node given an id.
## if an id is not provided, the default channel is used
## if a channel does not exist, its scene will be instantiated and set up
static func get_channel_node(id = null) -> Node:
	if id == null:
		return instance.channel_container.get_child(0)
	if instance.channel_container.has_node(str(id)):
		return instance.channel_container.get_node(str(id))
	var channel_node = chat_channel_scene.instantiate()
	instance.channel_container.add_child(channel_node)
	var tab_id = channel_node.get_index()
	channel_node.set_channel_name(id)
	
	(instance.channel_container as TabContainer).set_tab_hidden(tab_id, not SettingsHandler.opened_channels.has(SKELETON_KEY))
	
	return channel_node

static func get_current_channel_node() -> Node:
	return instance.channel_container.get_child(instance.channel_container.current_tab)

static func enable_channel(id: int):
	var tabber: TabContainer = instance.channel_container as TabContainer
	var tab_id = get_channel_node(id).get_index()
	tabber.set_tab_hidden(tab_id, false)
	if id not in SettingsHandler.opened_channels:
		SettingsHandler.opened_channels.append(id)
		SettingsHandler.save()
	if id == SKELETON_KEY:
		for tab_to_bone in range(tabber.get_tab_count()):
			tabber.set_tab_hidden(tab_to_bone, false)

static func disable_channel(id: int):
	var tabber: TabContainer = instance.channel_container as TabContainer
	var tab_id = get_channel_node(id).get_index()
	tabber.set_tab_hidden(tab_id, true)
	if id in SettingsHandler.opened_channels:
		SettingsHandler.opened_channels.erase(id)
		SettingsHandler.save()
	if id == SKELETON_KEY:
		for tab_to_bone in range(tabber.get_tab_count()):
			var tab_to_check: Control = tabber.get_tab_control(tab_to_bone)
			if tab_to_check is not ChatChannel:
				continue
			tab_to_check = tab_to_check as ChatChannel
			var signal_key = tab_to_check.id
			if signal_key is not int:
				continue
			signal_key = signal_key as int
			if not SettingsHandler.opened_channels.has(signal_key):
				tabber.set_tab_hidden(tab_to_bone, true)

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
			# CURRENT COMPUTER DOES [ COMPUTER 0 COMMUNICATE ] WANT DOST
			msg = [-119, -241, -86, -14, -241, 0, -196, -15, -127, -85]
		State.CONNECTED:
			# GOOD ; CURRENT COMPUTER DOES COMPUTER 0 COMMUNICATE CAN DOST
			msg = [-154, -2, -119, -241, -86, -241, 0, -196, -145, -85]
		State.FAILED_TO_CONNECT:
			# BAD ; CURRENT COMPUTER DOES COMPUTER 0 COMMUNICATE CAN NOT DOST
			msg = [-155, -2, -119, -241, -86, -241, 0, -196, -145, -29, -85]
		State.DISCONNECTING:
			# CURRENT COMPUTER AND COMPUTER 0 DOES [ COMMUNICATE ] WANT NOT MUTUAL DOST SMALL NEXT TIME WHEN
			msg = [-119, -241, -30, -241, 0, -86, -14, -196, -15, -127, -29, -186, -85, -109, -120, -65, -121]
		State.DISCONNECTED:
			# COMPUTER 0 DOES CURRENT COMPUTER COMMUNICATE NOT DOST
			msg = [-241, 0, -86, -119, -241, -196, -29, -85]
		State.WILL_AUTO_RECONNECT_SOON:
			# CURRENT COMPUTER DOES [ COMPUTER 0 COMMUNICATE ] WANT DOST $x ASEC NEXT WHEN
			msg = [-119, -241, -86, -14, -241, 0, -196, -15, -127, -85, int(args[0]), -69, -120, -121]
		State.UNKNOWN_WORD:
			# UNKNOWN SIGNAL IS [ %s, %s, %s, etc ]
			msg = [-124, -42, -100, -14]
			for idx in range(args.size()):
				if idx > 0:
					msg.append(-3)
				msg.append(str(args[idx]))
			msg.append(-15)
		State.INPUT_TOO_LONG:
			# COMPUTER DOES TRANSMISSION [ SIGNAL COUNT > 2000 ] COMMUNICATE CAN NOT DOST
			msg = [-241, -86, -43, -14, -42, -23, -32, Main.MAX_MESSAGE_LENGTH, -15, -196, -145, -29, -85]
		State.INPUT_ENCRYPT_TOO_SHORT:
			# COMPUTER DOES TRANSMISSION [ arg AND SIGNAL COUNT < 3 ] COMMUNICATE CAN NOT DOST
			msg = [-241, -86, -43, -14, args[0], -30, -42, -23, -33, 3, -15, -196, -145, -29, -85]
		State.INPUT_COMMAND_LENGTH_INVALID:
			# COMPUTER DOES TRANSMISSION [ arg AND SIGNAL COUNT = NOT 2 ] COMMUNICATE CAN NOT DOST
			msg = [-241, -86, -43, -14, args[0], -30, -42, -23, -4, -29, 2, -15, -196, -145, -29, -85]
		State.INPUT_LENGTH_INVALID:
			# one arg -> must be equal
			# two args -> range 
			if len(args) == 1:
				# COMPUTER DOES TRANSMISSION [ SIGNAL COUNT = NOT # ] COMMUNICATE CAN NOT DOST
				msg = [-241, -86, -43, -14, -42, -23, -4, -29, int(args[0]), -15, -196, -145, -29, -85]
		State.DUPLICATE_NAME:
			# SIGNAL [ - #] AND SIGNAL [ - #] IS SYMMETRIC; "%s"
			msg = [-42, -14, -1, absi(int(args[0])), -15, -30, -42, -14, -1, absi(int(args[1])), -15, -100, -229, -2, args[2]]

	new_message.message = msg
	# arbitrary impossible sender for purposes of chat seperators
	new_message.sender = -1574
	get_current_channel_node().add_message_node(new_message)
