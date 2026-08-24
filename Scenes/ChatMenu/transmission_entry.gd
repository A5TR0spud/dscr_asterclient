extends ChatEntry
class_name TransEntry
var trans: int = 0

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
var has_image: bool = false

@onready var context_buttons: HFlowContainer = $Body/Corpus/ContextButtons

var unknown_button = preload("res://Scenes/Common/unknown_signal_button.tscn")

func ready():
	transmission_node.get_popup().id_pressed.connect(transmit_pressed)
	callsign_node.self_modulate = Main.get_callsign_color(sender)
	tab_node.self_modulate = Main.get_callsign_color(sender)
	identicon_node.num = sender
	has_image = image_node.check_image(message)
	image_node.visible = has_image and SettingsHandler.image_default
	image_button_node.button_pressed = image_node.visible
	image_button_node.visible = has_image
	if not has_image:
		image_node.queue_free()
		image_button_node.queue_free()
	refresh_callsign()
	Main.instance.reload_nicknames.connect(refresh_callsign)

func refresh_callsign():
	callsign_node.text = Main.base_10_to_callsign(sender)
	if not NicknamesHandler.get_nick(sender).is_empty():
		callsign_node.text += " \'" + NicknamesHandler.get_nick(sender) + "\'"

func _physics_process(_delta):
	if timeago_node.visible:
		calc_time()
		timeago_node.text = time_ago

func refresh():
	timeago_node.text = time_ago
	transmission_node.set("popup/item_0/text", DictionaryHandler.get_or_default_signal_name(-40))
	var trx: String = str(trans % 512)
	while trx.length() < 3:
		trx = "0" + trx
	transmission_node.text = trx

func set_message_text(new_text: String):
	message_node.text = new_text
	is_clickable = false
	for but in context_buttons.get_children():
		if but is UnknownSignalButton:
			but.queue_free()
	# failsafe cap of 8 unknown signals just in case
	# shouldn't happen normally and defining them will show the rest
	# ergo a setting isn't warranted
	var unknown_cap: int = 8
	var unknowns: Array[int] = []
	for sig in message:
		if unknown_cap <= 0:
			break
		if sig >= 0:
			continue
		if unknowns.has(sig):
			continue
		if not DictionaryHandler.word_keys.has(sig):
			var new_button: UnknownSignalButton = unknown_button.instantiate()
			new_button.text = DictionaryHandler.get_or_default_signal_name(sig)
			new_button.sig = sig
			context_buttons.add_child(new_button)
			unknown_cap -= 1
			unknowns.append(sig)

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
	calc_time()
	timeago_node.text = time_ago
	timeago_node.visible = hovering
	hover_node.visible = hovering
	is_hovering = hovering

func _on_set_etc_visibility(visiblity: bool) -> void:
	etc_button_node.visible = visiblity

func _on_image_button_toggled(toggled_on: bool) -> void:
	image_node.visible = toggled_on

func _on_message_meta_clicked(meta: Variant) -> void:
	if Input.is_action_pressed("click_signal_modifier"):
		DictEditMenu.open(meta as int)

var is_hovering: bool = false
var is_clickable: bool = false

func _input(event):
	if event.is_action_pressed("click_signal_modifier") and is_hovering and not is_clickable:
		request_rewrite(true)
		if DisplayServer.cursor_get_shape() == DisplayServer.CURSOR_IBEAM:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND)
		is_clickable = true
	if (event.is_action_released("click_signal_modifier") or not is_hovering) and is_clickable:
		request_rewrite(false)
		if DisplayServer.cursor_get_shape() == DisplayServer.CURSOR_POINTING_HAND:
			DisplayServer.cursor_set_shape(DisplayServer.CURSOR_IBEAM)
		is_clickable = false
