@abstract class_name ChatEntry
extends VBoxContainer

var Timestamp: int = 0
var Message: Array = []
var TimeAgo: String = ""
var Collapsed: bool = true:
	set(value):
		var oldV: bool = Collapsed
		Collapsed = value
		if oldV != value:
			_evaluateCorpus()
var Sender: int = 0

func IsMessageTruncatable() -> bool:
	return Message.size() > SettingsHandler.TruncateMessageSize

func CalcTime():
	var timeago: float = absi(Timestamp - Time.get_ticks_msec())
	timeago *= 0.001
	timeago /= Main.He6HalfLife
	TimeAgo = DictionaryHandler.Signals2Words([floori(timeago), -69, -118, -121])

func _ready():
	Ready()
	hover_change.emit(false)
	_refresh()
	Collapsed = true
	CalcTime()
	Main.instance.ReloadDict.connect(_refresh)
	Main.instance.ReloadSettings.connect(_evaluateCorpus)
	self.mouse_entered.connect(hover_change.emit.bind(true))
	self.mouse_exited.connect(hover_change.emit.bind(false))

func _refresh():
	Refresh()
	_evaluateCorpus()

func _evaluateCorpus():
	var toShow: Array = Message
	set_etc_visibility.emit(IsMessageTruncatable())
	if Collapsed and IsMessageTruncatable():
		toShow = toShow.slice(0, SettingsHandler.TruncateMessageSize)
		toShow.append(-25)
	SetMessageText(
		DictionaryHandler.Signals2Words(toShow, SettingsHandler.DoFormatting)
	)

@abstract func Ready()
## Called when dictionary is reloaded
@abstract func Refresh()
@abstract func SetMessageText(newText: String)
signal hover_change(hovering: bool)
signal set_etc_visibility(visibility: bool)
