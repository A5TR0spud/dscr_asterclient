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

func _on_etc_button_toggled(_toggled_on):
	collapsed = not _toggled_on

func transmit_pressed(id: int) -> void:
	if id == 0:
		copy()

func copy():
	var o: Array[String] = []
	for i in message:
		if i >= 0:
			o.append(str(i))
		else:
			o.append("|" + str(i))
	DisplayServer.clipboard_set(" ".join(o))

func _on_hover_change(hovering: bool) -> void:
	calc_time()
	timeago_node.text = time_ago
	timeago_node.visible = hovering
	hover_node.visible = hovering

func _on_set_etc_visibility(visiblity: bool) -> void:
	etc_button_node.visible = visiblity

func _on_image_button_toggled(toggled_on: bool) -> void:
	image_node.visible = toggled_on
