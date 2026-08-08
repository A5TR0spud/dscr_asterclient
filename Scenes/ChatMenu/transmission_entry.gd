extends ChatEntry
class_name TransEntry
var Trans: int = 0

@onready var CS: Label = $Header/Cbox/Callsign
@onready var TR: MenuButton = $Header/Trans
@onready var TI: Label = $Header/HoverBox/Timeago
@onready var MG: RichTextLabel = $Body/Corpus/Message
@onready var TAB: VSeparator = $Body/MessageIndent
@onready var ID: Identicon = $Header/Cbox/Identicon
@onready var HOV: HBoxContainer = $Header/HoverBox
@onready var ETC: Button = $Body/Corpus/ContextButtons/EtcButton

@onready var IMG: VisualizeNode = $Body/Corpus/VisualizeNode
@onready var IMGB: Button = $Body/Corpus/ContextButtons/ImageButton
var HasImage: bool = false

func Ready():
	TR.get_popup().id_pressed.connect(TRPressed)
	CS.self_modulate = Main.GetCallsignColor(Sender)
	TAB.self_modulate = Main.GetCallsignColor(Sender)
	ID.Num = Sender
	CS.text = Main.base10ToCallsign(Sender)
	HasImage = IMG.CheckImage(Message)
	IMG.visible = HasImage and SettingsHandler.ImageDefault
	IMGB.button_pressed = IMG.visible
	IMGB.visible = HasImage

func _physics_process(_delta):
	if TI.visible:
		CalcTime()
		TI.text = TimeAgo

func Refresh():
	TI.text = TimeAgo
	TR.set("popup/item_0/text", DictionaryHandler.GetOrDefaultSignalName(-40))
	var trx: String = str(Trans % 512)
	while trx.length() < 3:
		trx = "0" + trx
	TR.text = trx

func SetMessageText(newText: String):
	MG.text = newText

func _on_etc_button_toggled(_toggled_on):
	Collapsed = not _toggled_on

func TRPressed(id: int) -> void:
	if id == 0:
		Copy()

func Copy():
	var o: Array[String] = []
	for i in Message:
		if i >= 0:
			o.append(str(i))
		else:
			o.append("|" + str(i))
	DisplayServer.clipboard_set(" ".join(o))

func _on_hover_change(hovering: bool) -> void:
	CalcTime()
	TI.text = TimeAgo
	TI.visible = hovering
	HOV.visible = hovering

func _on_set_etc_visibility(visiblity: bool) -> void:
	ETC.visible = visiblity

func _on_image_button_toggled(toggled_on: bool) -> void:
	IMG.visible = toggled_on
