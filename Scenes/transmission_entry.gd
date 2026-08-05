extends VBoxContainer
class_name TransEntry
var Sender: int = 0
var Trans: int = 0
var Timestamp: int = 0
var Message: Array[int] = []

@onready var CSL: Label = $Header/Cbox/CallsignLabel
@onready var CS: Label = $Header/Cbox/Callsign
@onready var TR: Label = $Header/Tbox/Trans
@onready var TRL: Label = $Header/Tbox/TransLabel
@onready var TI: Label = $Header/Timeago
@onready var MG: RichTextLabel = $Body/Message
@onready var TAB: VSeparator = $Body/MessageIndent
@onready var ID: ColorRect = $Header/Cbox/Identicon

func _ready():
	Main.instance.ReloadDict.connect(Refresh)
	CS.self_modulate = Main.GetCallsignColor(Sender)
	TAB.self_modulate = Main.GetCallsignColor(Sender)
	ID.material.set_shader_parameter("Value", Sender)
	ID.color = Main.GetCallsignColor(Sender)
	Refresh()

func _physics_process(_delta):
	CalcTime()

func CalcTime():
	var timeago: float = absi(Timestamp - Time.get_ticks_msec())
	timeago *= 0.001
	timeago /= Main.He6HalfLife
	TI.text = DictionaryHandler.Signals2Words([floori(timeago), -69, -118, -121])

func Refresh():
	CalcTime()
	CSL.text = DictionaryHandler.GetOrDefaultSignalName(-128) + " "
	CS.text = Main.base10ToCallsign(Sender)
	var trx: String = str(Trans % 512)
	while trx.length() < 3:
		trx = "0" + trx
	TRL.text = DictionaryHandler.GetOrDefaultSignalName(-43) + " "
	TR.text = trx
	MG.text = DictionaryHandler.Signals2Words(Message, SettingsHandler.DoFormatting)
