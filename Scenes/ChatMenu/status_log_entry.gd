extends ChatEntry
class_name StatusLogEntry

@onready var timeago_node: Label = $Header/Timeago
@onready var message_node: RichTextLabel = $Body/Corpus/Message
@onready var tab_node: VSeparator = $Body/MessageIndent
@onready var etc_button_node: Button = $Body/Corpus/ContextButtons/EtcButton

var translation_key: String = ""
var arguments: Variant = []

func ready():
	Main.instance.reload_dict.connect(refresh)
	Main.instance.localization_reload.connect(refresh.bind(true))
	refresh()

func _physics_process(_delta):
	calc_time()
	timeago_node.text = get_timeago_string()

func get_color() -> Color:
	return Color.WHITE

func refresh(from_locale: bool = false):
	if not translation_key.is_empty():
		message = Localizer.raw_translate(translation_key)
		if from_locale:
			request_rewrite(false)

func set_message_text(_new_text: String):
	message_node.text = _new_text.format(arguments)

func supports_bbcode() -> bool:
	return false

func _on_delete_button_pressed():
	queue_free()

func _on_etc_button_toggled(toggled_on):
	collapsed = not toggled_on

func _on_set_etc_visibility(visibility: bool):
	etc_button_node.visible = visibility
