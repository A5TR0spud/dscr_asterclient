extends MarginContainer
class_name ChatChannel
@onready var chat_display = $ScrollContainer/MarginContainer/ChatDisplay
@onready var scroll_container: AutoScrollContainer = $ScrollContainer
@onready var scroll_bar: VScrollBar = $ScrollContainer.get_v_scroll_bar()
@onready var scroll_down_button: Button = $ScrollToNew
static var trx_scene = preload("res://Scenes/ChatMenu/transmission_entry.tscn")
var default_channel: bool = true
var id = null
var enable_notification: bool = false

const HIDE_EXCESS_TRANSMISSIONS: int = 32

var shown_transmissions: int = 0
var logged_history: Array[Dictionary] = []

func _ready() -> void:
	chat_display.child_entered_tree.connect(Chat.on_chat_display_child_entered_tree.bind(chat_display))
	chat_display.child_exiting_tree.connect(Chat.on_chat_display_child_exiting_tree.bind(chat_display))
	Main.instance.reload_dict.connect(update_name)
	scroll_bar.value_changed.connect(_on_scroll)
	scroll_down_button.hide()

func add_message_node(message: ChatEntry):
	if message is TransEntry:
		logged_history.append({
			"m": PackedInt64Array(message.message),
			"time": message.timestamp,
			"sender": message.sender,
			"trx": message.trans
		})
	shown_transmissions += 1
	chat_display.add_child(message)
	
	if Chat.instance.channel_container.current_tab != get_index():
		set_notification()

func _input(event):
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_page_up", true):
		scroll_bar.value -= scroll_bar.page * 0.8
		accept_event()
	elif event.is_action_pressed("ui_page_down", true):
		scroll_bar.value += scroll_bar.page * 0.8
		accept_event()

func _on_scroll(val):
	if val < 0.01:
		try_show_history()
	elif scroll_container.is_scrolled_to_bottom():
		try_hide_history()
	scroll_down_button.visible = not scroll_container.bottom_is_visible()

func try_show_history() -> bool:
	if logged_history.size() <= shown_transmissions:
		return false
	var unshown_to_add: Dictionary = logged_history[logged_history.size() - shown_transmissions - 1]
	var trx: TransEntry = trx_scene.instantiate()
	trx.message = unshown_to_add["m"]
	trx.timestamp = unshown_to_add["time"]
	trx.sender = unshown_to_add["sender"]
	trx.trans = unshown_to_add["trx"]
	chat_display.add_child(trx)
	chat_display.move_child(trx, 0)
	scroll_bar.set_value_no_signal.call_deferred(0.1)
	shown_transmissions += 1
	return true

func try_hide_history():
	if shown_transmissions > HIDE_EXCESS_TRANSMISSIONS and scroll_container.is_scrolled_to_bottom():
		for c in chat_display.get_children():
			if scroll_bar.page + 64 >= scroll_bar.max_value - scroll_bar.min_value:
				return
			if c is StatusLogEntry:
				c.queue_free()
			if c is TransEntry:
				c.queue_free()
				shown_transmissions -= 1
				if shown_transmissions <= HIDE_EXCESS_TRANSMISSIONS:
					break

func _on_chat_display_child_entered_tree(_node):
	try_hide_history()

func set_channel_name(_id):
	self.name = str(_id)
	default_channel = false
	self.id = _id
	update_name()

func set_notification():
	enable_notification = true
	update_name()

func clear_notification():
	enable_notification = false
	update_name()

func update_name():
	var sig = []
	if enable_notification:
		sig.append(-124)
	
	if default_channel:
		sig.append_array([-111, Chat.CHANNEL_SELECTOR])
	else:
		sig.append(id)
		
	Chat.instance.channel_container.set_tab_title(
		get_index(),
		DictionaryHandler.signals_to_words(sig)
	)

func get_prefix() -> Array[int]:
	if default_channel:
		return []
	else:
		return [Chat.CHANNEL_SELECTOR, id]


func _on_scroll_to_new_pressed():
	scroll_container.scroll_to_bottom()
	try_hide_history()
