extends MarginContainer
class_name ChatChannel
@onready var chat_display = $ScrollContainer/MarginContainer/ChatDisplay
var default_channel: bool = true
var id = null
var enable_notification: bool = false

func _ready() -> void:
	chat_display.child_entered_tree.connect(Chat.on_chat_display_child_entered_tree.bind(chat_display))
	chat_display.child_exiting_tree.connect(Chat.on_chat_display_child_exiting_tree.bind(chat_display))
	Main.instance.reload_dict.connect(update_name)
	
func add_message_node(message: Node):
	chat_display.add_child(message)
	
	if Chat.instance.channel_container.current_tab != get_index():
		set_notification()

func set_channel_name(id):
	self.name = str(id)
	default_channel = false
	self.id = id
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
