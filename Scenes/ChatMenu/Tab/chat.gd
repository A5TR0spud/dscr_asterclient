extends VBoxContainer
class_name Chat

static var history: History = null

static var instance: Chat
static var transmission_entry_scene = preload("uid://d4neakrhevfia")
static var status_log_entry_scene = preload("uid://bfuqifdrv6kq3")
static var chat_channel_scene = preload("uid://c7bn3w1ijabx4")
@onready var channel_container: TabContainer = $TabContainer
@onready var main_channel: ChatChannel = $TabContainer/Main
@onready var tabbar: TabBar = channel_container.get_tab_bar()
@onready var trans_edit: TransmissionEdit = $BottomBar/MessageEdit
@onready var edit_side_options: Control = $BottomBar/SideOptionsWrapper/SideOptions
@onready var quick_transmission_button: IconButton = $BottomBar/SideOptionsWrapper/SideOptions/QuickTransmission
@onready var quick_transmission_panel: PanelContainer = $BottomBar/SideOptionsWrapper/SideOptions/QuickTransmission/Control/PanelContainer
@onready var quick_transmission_search: LineEdit = $BottomBar/SideOptionsWrapper/SideOptions/QuickTransmission/Control/PanelContainer/VBoxContainer/QTSearch
@onready var quick_transmission_list: ItemList = $BottomBar/SideOptionsWrapper/SideOptions/QuickTransmission/Control/PanelContainer/VBoxContainer/QTList
@onready var parse_bar_word: RichTextLabel = $PWordLabel

func _enter_tree():
	instance = self

func _ready():
	hide_qt_panel()
	Main.instance.reload_settings.connect(open_loaded_channels)
	open_loaded_channels()
	main_channel.try_show_history()
	#refresh_can_close()
	refresh_little_menu()
	tabbar.tab_close_pressed.connect(close_tab_from_button)
	Main.instance.reload_library.connect(refresh_little_menu)
	_refresh_parse_bar()

#region Chat

const COMMAND_LEAVE: int = -65533
const COMMAND_JOIN: int = -65534
const CHANNEL_SELECTOR: int = -65535
const SKELETON_KEY: int = -65536

signal ready_for_history

static var ten_most_recent_transmissions: Array[int] = [] as Array[int]

static func load_history() -> void:
	history = History.new()
	if ResourceLoader.exists(SaveSystem._history_path()):
		var tmp = ResourceLoader.load(SaveSystem._history_path())
		if tmp and tmp is History and is_instance_valid(tmp):
			history = tmp
	instance.ready_for_history.emit()
	#var _c: ChatEntryNode = history.all_channel_head
	#while _c:
	#	print(_c.trx)
	#	_c = _c.earlier_in_all

static func save_history() -> void:
	ResourceSaver.save(history, SaveSystem._history_path())
	#var _c: ChatEntryNode = history.all_channel_head
	#while _c:
	#	print(_c.trx)
	#	_c = _c.earlier_in_all

func close_tab_from_button(idx: int):
	var c: ChatChannel = channel_container.get_child(idx)
	if c.id is not int:
		return
	disable_channel(c.id)
	SoundManager.play_sound(SoundManager.Sounds.CLOSE_UI)

#func refresh_can_close():
	#return
	#tabbar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_NEVER if main_channel.visible else TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY

static func get_active_channel() -> ChatChannel:
	var idx: int = instance.channel_container.current_tab
	return instance.channel_container.get_child(idx)

func open_loaded_channels():
	for tab_idx in range(0, channel_container.get_child_count()):
		var tab: ChatChannel = channel_container.get_child(tab_idx)
		if tab.id in SettingsHandler.opened_channels or tab.id == null:
			continue
		instance.channel_container.set_tab_hidden(tab_idx, true)
	for channel_id in SettingsHandler.opened_channels:
		enable_channel(channel_id)
	channel_container.move_child(main_channel, SettingsHandler.where_is_main_chat)

static func new_transmission(packet: PackedStringArray) -> void:
	var sender: int = packet[0].to_int()
	var transmission_number: int = packet[1].to_int()
	var integer_message: Array[int] = []
	for part in packet.slice(2):
		integer_message.append(part.to_int())
	
	var new_message: TransEntry = transmission_entry_scene.instantiate()
	new_message.timestamp = Time.get_ticks_msec()
	new_message.sender = sender
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
		#print(integer_message)
	
	# this is for powering off/on the app
	if not is_instance_valid(history):
		load_history()
	if is_instance_valid(history):
		var _c: ChatEntryNode = history.get_at_cyclic_index(history.last_valid())
		var _i: int = 0
		while _c and _i <= 10:
			#print(_c.trx, " : ", transmission_number)
			#print(_c.sender, " : ", sender)
			#print(_c.message, " : ", integer_message)
			#print("-------------")
			if (
				_c.trx == transmission_number and _c.sender == sender
				and _c.message.size() == integer_message.size()
			):
				var thats_a_dupe: bool = true
				for _j: int in range(_c.message.size()):
					if _c.message[_j] != integer_message[_j]:
						thats_a_dupe = false
						break
				if thats_a_dupe:
					return
			_i += 1
			_c = history.get_at_cyclic_index(history.last_valid() - _i)
	
	var channel: ChatChannel = get_channel_node(channel_id)
	var spooky_channel: ChatChannel = get_channel_node(SKELETON_KEY)
	
	new_message.message = integer_message
	
	if (
		Confetti.evaluate_confetti(integer_message) and
		(
			(get_active_channel().id == channel_id and
			channel.scroll_container.bottom_is_visible())
			or
			(get_active_channel().id == SKELETON_KEY and
			spooky_channel.scroll_container.bottom_is_visible())
		) and
		instance.is_visible_in_tree()
	):
		print("confetti!")
		Confetti.burst()
	
	if (
		(new_message.sender != Main.instance.previously_accepted_callsign)
		and (
			not instance.get_window().has_focus() or
			(get_active_channel().id != channel_id and get_active_channel().id != SKELETON_KEY) or
			not channel.scroll_container.bottom_is_visible()
		)
		and channel_is_available(channel_id)
	):
		SoundManager.play_sound(SoundManager.Sounds.NOTIFICATION)
		var target_cs: String = String.num_int64(Main.instance.previously_accepted_callsign, 8)
		var target_cs2: String = Main.base_10_to_callsign(Main.instance.previously_accepted_callsign)
		var composite_cs: String = ""
		for num: int in integer_message:
			if num < 0:
				if composite_cs == target_cs or composite_cs == target_cs2:
					break
				composite_cs = ""
				continue
			composite_cs += str(num)
		if composite_cs == target_cs or composite_cs == target_cs2:
			SoundManager.play_sound(SoundManager.Sounds.PING)
	var ghost_to_skeleton: bool = true
	if channel_id == SKELETON_KEY:
		new_message.key = SKELETON_KEY
		ghost_to_skeleton = false
	channel.add_message_node(new_message)
	
	if get_active_channel().id != channel_id and get_active_channel().id != SKELETON_KEY:
		spooky_channel.set_notification()
	
	if ghost_to_skeleton:
		var ske_message: TransEntry = transmission_entry_scene.instantiate()
		ske_message.timestamp = new_message.timestamp
		ske_message.sender = new_message.sender
		ske_message.trans = new_message.trans
		ske_message.message = integer_message
		ske_message.key = channel_id
		spooky_channel.add_message_node(ske_message)
	
	if is_instance_valid(history):
		history.add(sender, channel_id, transmission_number, integer_message)

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
	DUPLICATE_NUMBER,
}

static func channel_is_available(id = null) -> bool:
	if id == null:
		return true
	var has: bool = instance.channel_container.has_node(str(id))
	if not has:
		return false
	var node = instance.channel_container.get_node(str(id))
	return not instance.channel_container.is_tab_hidden(node.get_index())

static func open_channel_from_selector(id: int) -> void:
	if get_active_channel().id == id:
		return
	if get_active_channel().id == SKELETON_KEY:
		return
	var has_skeleton_key := SKELETON_KEY in SettingsHandler.opened_channels
	var has_key := id in SettingsHandler.opened_channels
	if has_skeleton_key and not has_key:
		id = SKELETON_KEY
	Chat.get_channel_node(id)
	Chat.focus_channel(id)

## gets channel node given an id.
## if an id is not provided, the default channel is used
## if a channel does not exist, its scene will be instantiated and set up
static func get_channel_node(id = null) -> ChatChannel:
	if id == null:
		return instance.main_channel
	if instance.channel_container.has_node(str(id)):
		return instance.channel_container.get_node(str(id))
	var channel_node: ChatChannel = chat_channel_scene.instantiate()
	instance.channel_container.add_child(channel_node)
	var tab_id = channel_node.get_index()
	channel_node.set_channel_name(id)
	channel_node.try_show_history()
	
	instance.channel_container.set_tab_hidden(tab_id, not SettingsHandler.opened_channels.has(tab_id))
	#instance.channel_container.set_tab_hidden(tab_id, not SettingsHandler.opened_channels.has(SKELETON_KEY))
	
	return channel_node

static func get_current_channel_node() -> ChatChannel:
	return instance.channel_container.get_child(instance.channel_container.current_tab)

static func enable_channel(id: int, save: bool = true):
	var tabber: TabContainer = instance.channel_container
	var tab_id = get_channel_node(id).get_index()
	tabber.set_tab_hidden(tab_id, false)
	if save and id not in SettingsHandler.opened_channels:
		SettingsHandler.opened_channels.append(id)
		SettingsHandler.save()
	if id == SKELETON_KEY:
		for tab_to_bone in range(tabber.get_tab_count()):
			var bone_id: Variant = (tabber.get_child(tab_to_bone) as ChatChannel).id
			if bone_id is not int:
				continue
			tabber.set_tab_hidden(tab_to_bone, not bone_id in SettingsHandler.opened_channels)

static func disable_channel(id: int):
	var tabber: TabContainer = instance.channel_container
	var tab_id = get_channel_node(id).get_index()
	tabber.set_tab_hidden(tab_id, true)
	if id in SettingsHandler.opened_channels:
		SettingsHandler.opened_channels.erase(id)
		instance._save_tab_order()
	#if id == SKELETON_KEY:
	#	for tab_to_bone in range(tabber.get_tab_count()):
	#		var tab_to_check: Control = tabber.get_tab_control(tab_to_bone)
	#		if tab_to_check is not ChatChannel:
	#			continue
	#		tab_to_check = tab_to_check as ChatChannel
	#		var signal_key = tab_to_check.id
	#		if signal_key is not int:
	#			continue
	#		signal_key = signal_key as int
	#		if not SettingsHandler.opened_channels.has(signal_key):
	#			tabber.set_tab_hidden(tab_to_bone, true)

static func focus_channel(id: int):
	enable_channel(id, false)
	get_channel_node(id).visible = true

func _update_skeleton_key_notification() -> void:
	for c: ChatChannel in channel_container.get_children():
		if c.id == SKELETON_KEY:
			continue
		if c.has_notification():
			return
	get_channel_node(SKELETON_KEY).clear_notification()

func _on_tab_container_tab_changed(tab: int) -> void:
	var cha: ChatChannel = channel_container.get_child(tab)
	cha.clear_notification()
	if cha.id != SKELETON_KEY:
		_update_skeleton_key_notification()
	var debone_zone: bool = SKELETON_KEY not in SettingsHandler.opened_channels
	for c: ChatChannel in channel_container.get_children():
		if cha.id == SKELETON_KEY:
			c.clear_notification()
		if debone_zone:
			continue
		if c.id is not int:
			continue
		if c.id in SettingsHandler.opened_channels:
			continue
		if c.is_visible_in_tree():
			continue
		disable_channel(c.id)
	#refresh_can_close()

static func new_log(state: State, args: Array = []) -> void:
	var new_message: StatusLogEntry = status_log_entry_scene.instantiate()
	new_message.timestamp = Time.get_ticks_msec()
	match state:
		State.CONNECTING:
			new_message.translation_key = "SYSTEM_CONNECTING"
		State.CONNECTED:
			new_message.translation_key = "SYSTEM_CONNECTED"
		State.FAILED_TO_CONNECT:
			new_message.translation_key = "SYSTEM_CONNECTION_FAILED"
		State.DISCONNECTING:
			new_message.translation_key = "SYSTEM_DISCONNECTING"
		State.DISCONNECTED:
			new_message.translation_key = "SYSTEM_DISCONNECTED"
		State.WILL_AUTO_RECONNECT_SOON:
			new_message.translation_key = "SYSTEM_WILL_RECONNECT"
			new_message.translation_plural_n_or_null = int(args[0])
			new_message.arguments = [int(args[0])]
		State.UNKNOWN_WORD:
			# UNKNOWN SIGNAL IS [ %s, %s, %s, etc ]
			var inner: String = ""
			for idx in range(args.size()):
				if idx > 0:
					inner += " "
				inner += str(args[idx])
			new_message.translation_key = "SYSTEM_UNKNOWN_SIGNAL"
			new_message.arguments = [inner]
		State.INPUT_TOO_LONG:
			new_message.translation_key = "SYSTEM_TOO_LONG"
			new_message.arguments = {"maxLength": Main.MAX_MESSAGE_LENGTH, "trxSize": args[0]}
		State.INPUT_ENCRYPT_TOO_SHORT:
			new_message.translation_key = "SYSTEM_CHANNEL_INPUT_TOO_SHORT"
			new_message.arguments = args
		State.INPUT_COMMAND_LENGTH_INVALID:
			new_message.translation_key = "SYSTEM_INPUT_LENGTH_INVALID_TWO"
			new_message.arguments = args
		State.INPUT_LENGTH_INVALID:
			# one arg -> must be equal
			# two args -> range
			if len(args) == 1:
				new_message.translation_key = "SYSTEM_INPUT_LENGTH_INVALID_VAR"
				new_message.arguments = args
		State.DUPLICATE_NAME:
			new_message.translation_key = "SYSTEM_DUPLICATE_NAME"
			new_message.arguments = {
				"sig0": absi(int(args[0])),
				"sig1": absi(int(args[1])),
				"name": args[2]
			}
		State.DUPLICATE_NUMBER:
			new_message.translation_key = "SYSTEM_DUPLICATE_NUMBER"
			new_message.arguments = args
	
	# arbitrary impossible sender for purposes of chat seperators
	new_message.sender = -1574
	get_current_channel_node().add_message_node(new_message)

func _on_message_edit_submit_text(message: String):
	get_current_channel_node().scroll_container.scroll_to_bottom()
	var send_result: Array = Main.instance.send_message(message.remove_char(ord(TransmissionEdit.DELIMITER_CHARACTER)))
	if send_result[0]:
		trans_edit.text = ""
	match send_result[1]:
		Main.MessageCompilationResult.MESSAGE_SENT:
			SoundManager.play_sound(SoundManager.Sounds.MESSAGE_SENT)
		Main.MessageCompilationResult.MESSAGE_FAILED:
			SoundManager.play_sound(SoundManager.Sounds.FAIL)
		Main.MessageCompilationResult.COMMAND_SENT:
			SoundManager.play_sound(SoundManager.Sounds.COMMAND_ACCEPTED)
		Main.MessageCompilationResult.SHOW_SENT:
			SoundManager.play_sound(SoundManager.Sounds.OPEN_UI)
		Main.MessageCompilationResult.HIDE_SENT:
			SoundManager.play_sound(SoundManager.Sounds.CLOSE_UI)
		Main.MessageCompilationResult.REDUNDANT:
			SoundManager.play_sound(SoundManager.Sounds.REDUNDANT)

func _save_tab_order():
	var new_order: PackedInt64Array = []
	var idx: int = 0
	for c: ChatChannel in channel_container.get_children():
		if c.id == null:
			SettingsHandler.where_is_main_chat = idx
		if c.id is not int:
			continue
		if c.id not in SettingsHandler.opened_channels:
			continue
		idx += 1
		new_order.append(c.id)
	SettingsHandler.opened_channels = new_order
	SettingsHandler.save()

func _on_tab_container_active_tab_rearranged(_idx_to):
	_save_tab_order()

func _on_save_cooldown_timeout():
	save_history()

#endregion

func refresh_little_menu() -> void:
	quick_transmission_button.visible = not LibraryHandler.get_all_transmissions().is_empty()
	edit_side_options.visible = quick_transmission_button.visible

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if Rect2(Vector2.ZERO, quick_transmission_panel.size).has_point(quick_transmission_panel.get_local_mouse_position()):
				return
			if Rect2(Vector2.ZERO, quick_transmission_button.size).has_point(quick_transmission_button.get_local_mouse_position()):
				return
			hide_qt_panel()

#region Little Menu

func hide_qt_panel():
	quick_transmission_panel.hide()

func popup_qt_panel():
	quick_transmission_list.get_v_scroll_bar().value = 0
	quick_transmission_panel.show()
	quick_transmission_panel.reset_size.call_deferred()
	quick_transmission_search.clear()
	_do_qt_search()
	quick_transmission_search.grab_focus()

func _on_quick_transmission_pressed():
	if quick_transmission_panel.visible:
		hide_qt_panel()
	else:
		popup_qt_panel()

func _on_qt_search_text_changed(new_text: String):
	_do_qt_search(new_text)

func _on_qt_list_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int):
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	_select_qt_item(index)

func _select_qt_item(idx: int):
	var c0: int = trans_edit.get_caret_column()
	var l0: int = trans_edit.get_caret_line()
	trans_edit.insert_text_at_caret(
		DictionaryHandler.signals_to_words(
			LibraryHandler.get_transmission(
				quick_transmission_list.get_item_text(idx)
			),
			true
		)
	)
	var c1: int = trans_edit.get_caret_column()
	var l1: int = trans_edit.get_caret_line()
	trans_edit.grab_focus()
	trans_edit.select(l0, c0, l1, c1)
	hide_qt_panel()

func _do_qt_search(new_text: String = ""):
	quick_transmission_list.clear()
	var order: Array = LibraryHandler.get_all_transmissions()
	if new_text.is_empty():
		order.sort()
	else:
		order = AutocompleteManager.get_dl_candidates(
			new_text, order, 10
		)
	for s: String in order:
		quick_transmission_list.add_item(s)

func _on_qt_search_gui_input(event: InputEvent):
	var selected = quick_transmission_list.get_selected_items()
	var idx = selected[0] if not selected.is_empty() else 0
	if event.is_action_pressed("ui_down", true):
		idx = min(idx + 1, quick_transmission_list.item_count - 1)
		quick_transmission_list.select(idx)
		quick_transmission_list.ensure_current_is_visible()
		accept_event()
		return
	if event.is_action_pressed("ui_up", true):
		idx = max(idx - 1, 0)
		quick_transmission_list.select(idx)
		quick_transmission_list.ensure_current_is_visible()
		accept_event()
		return
	if event.is_action_pressed("autocomplete_accept") or event.is_action_pressed("ui_text_submit"):
		_select_qt_item(idx)
		accept_event()
		return
	if event.is_action_pressed("ui_close_dialog"):
		hide_qt_panel()
		accept_event()
		return

#endregion

#region Parse Bar

func _on_message_edit_caret_changed():
	_refresh_parse_bar()

func _on_message_edit_text_changed():
	_refresh_parse_bar()

func _on_message_edit_text_set():
	_refresh_parse_bar()

func _refresh_parse_bar():
	var input: String = trans_edit.get_selected_text()
	
	if input.length() > 128:
		input = input.left(128)
	
	if not input:
		input = trans_edit.get_line_wrapped_text(trans_edit.get_caret_line())[trans_edit.get_caret_wrap_index()]
	
	var result: String = ""
	
	#print(input)
	
	TransmissionCompilation.compile_text(input)
	var d := TransmissionCompilation.get_as_data_dict()
	var starts: PackedInt32Array = d["starts"]
	var lengths: PackedInt32Array = d["lengths"]
	var sigs: PackedInt64Array = d["signals"]
	var prevend: int = 0
	for idx: int in range(starts.size() + 1):
		var start: int = starts[idx] if idx < starts.size() else input.length()
		var end: int = start + lengths[idx] if idx < starts.size() else 0
		result += " "
		if start > prevend:
			var bad: String = input.substr(prevend, start - prevend).strip_edges()
			if bad:
				result += str(
					"[color=#ff5566cc]",
					bad,
					"[/color] "
				)
		if idx < starts.size():
			var sig: int = sigs[idx]
			if sig < 0:
				result += str(
					"[hint='|",
					sig,
					"']",
					DictionaryHandler.get_or_default_signal_name(sig).replace("[", "[lb]"),
					"[/hint]"
				)
			else:
				result += DictionaryHandler.get_or_default_signal_name(sig).replace("[", "[lb]")
		prevend = end
	
	parse_bar_word.text = result.strip_edges()
	get_viewport().update_mouse_cursor_state.call_deferred()

#endregion
