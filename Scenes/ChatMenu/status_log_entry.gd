extends ChatEntry
class_name StatusLogEntry

@onready var timeago_node: Label = $Header/Timeago
@onready var message_node: RichTextLabel = $Body/Corpus/Message
@onready var tab_node: VSeparator = $Body/MessageIndent
@onready var etc_button_node: Button = $Body/Corpus/ContextButtons/EtcButton

func ready():
	Main.instance.reload_dict.connect(refresh)

func _physics_process(_delta):
	calc_time()
	timeago_node.text = time_ago

func refresh():
	pass

func set_message_text(new_text: String):
	message_node.text = new_text

func supports_color() -> bool:
	return false

func _on_delete_button_pressed():
	queue_free()

func _on_etc_button_toggled(toggled_on):
	collapsed = not toggled_on

func _on_set_etc_visibility(visibility: bool):
	etc_button_node.visible = visibility
