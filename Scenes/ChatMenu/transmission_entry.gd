extends ChatEntry
class_name TransEntry
var trans: int = 0
var is_image_open: bool = false
@export var image_open_override: bool = false
@export var stasis: bool = false
@export var delete_empty_parses: bool = true

# evil
@onready var callsign_node: Label = $Header/Cbox/Callsign
@onready var transmission_node: MenuButton = $Header/Trans
@onready var timeago_node: Label = $Header/HoverBox/Timeago
@onready var message_node: RichTextLabel = $Body/Corpus/Message
@onready var tab_node: VSeparator = $Body/MessageIndent
@onready var identicon_node: Identicon = $Header/Cbox/Identicon
@onready var hover_node: HBoxContainer = $Header/HoverBox
@onready var etc_button_node: Button = $Body/Corpus/ContextButtons/EtcButton

@onready var image_node: VisualizeNode = $Body/Corpus/VisualizeNode
@onready var image_button_node: Button = $Body/Corpus/ContextButtons/ImageButton

@onready var context_buttons: HFlowContainer = $Body/Corpus/ContextButtons

func ready():
	transmission_node.get_popup().id_pressed.connect(transmit_pressed)
	is_image_open = SettingsHandler.image_default or image_open_override
	try_parses()
	refresh_callsign()
	Main.instance.reload_nicknames.connect(refresh_callsign)
	if stasis:
		hover_node.visible = false

func get_color() -> Color:
	return Main.get_callsign_color(sender)

func try_parses():
	var has_image: bool = image_node.check_image(message)
	image_node.visible = has_image and is_image_open
	image_button_node.set_pressed_no_signal(image_node.visible)
	image_button_node.visible = has_image
	if not has_image and delete_empty_parses:
		image_node.queue_free()
		image_button_node.queue_free()

func refresh_callsign():
	callsign_node.text = Main.base_10_to_callsign(sender)
	if not NicknamesHandler.get_nick(sender).is_empty():
		callsign_node.text += " \'" + NicknamesHandler.get_nick(sender) + "\'"
	callsign_node.self_modulate = Main.get_callsign_color(sender)
	tab_node.self_modulate = Main.get_callsign_color(sender)
	identicon_node.num = sender

func _physics_process(_delta):
	if timeago_node.is_visible_in_tree():
		calc_time()
		timeago_node.text = get_timeago_string()

func override_transmission_label(text: String):
	transmission_node.text = text

func refresh():
	timeago_node.text = get_timeago_string()
	transmission_node.set("popup/item_0/text", DictionaryHandler.get_or_default_signal_name(-40))
	transmission_node.text = str(trans % 512).pad_zeros(3)

func set_message_text(new_text: String):
	message_node.text = new_text
	is_clickable = false

func _on_etc_button_toggled(_toggled_on):
	collapsed = not _toggled_on

func transmit_pressed(id: int) -> void:
	if id == 0:
		copy_as_signals()

func copy_as_signals():
	var o: Array[String] = []
	for i in message:
		if i >= 0:
			o.append(str(i))
		else:
			o.append("|" + str(i))
	DisplayServer.clipboard_set(" ".join(o))

func supports_bbcode() -> bool:
	return true

func _on_hover_change(hovering: bool) -> void:
	if stasis:
		return
	calc_time()
	timeago_node.text = get_timeago_string()
	hover_node.visible = hovering
	is_hovering = hovering
	_handle_clickables()

func _on_set_etc_visibility(visiblity: bool) -> void:
	etc_button_node.visible = visiblity

func _on_image_button_toggled(toggled_on: bool) -> void:
	image_node.visible = toggled_on
	is_image_open = toggled_on

func _on_message_meta_clicked(meta: Variant) -> void:
	if Input.is_action_pressed("click_signal_modifier"):
		DictEditMenu.open(meta as int)

var is_hovering: bool = false
var is_clickable: bool = false

func _handle_clickables():
	var selected_from: int = message_node.get_selection_from()
	var selected_to: int = message_node.get_selection_to()
	if selected_from >= 0 and selected_to >= 0:
		return
	if Input.is_action_pressed("click_signal_modifier") and is_hovering and not is_clickable:
		request_rewrite(true)
		warp_mouse.call_deferred(get_local_mouse_position())
		is_clickable = true
	if (not Input.is_action_pressed("click_signal_modifier") or not is_hovering) and is_clickable:
		request_rewrite(false)
		if DisplayServer.cursor_get_shape() == DisplayServer.CURSOR_POINTING_HAND:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_IBEAM)
		is_clickable = false

func _input(_event):
	_handle_clickables()
