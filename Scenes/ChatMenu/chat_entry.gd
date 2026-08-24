@abstract class_name ChatEntry
extends VBoxContainer

var timestamp: int = 0
var message: Array = []
var time_ago: String = ""
var collapsed: bool = true:
	set(value):
		var old_value: bool = collapsed
		collapsed = value
		if old_value != value:
			_evaluate_corpus()
var sender: int = 0

func is_message_truncatable() -> bool:
	return message.size() > SettingsHandler.truncate_message_size

func calc_time():
	var timeago: float = absi(timestamp - Time.get_ticks_msec())
	timeago *= 0.001
	timeago /= Main.HE6_HALF_LIFE
	time_ago = DictionaryHandler.signals_to_words([floori(timeago), -69, -118, -121])

func _ready():
	ready()
	hover_change.emit(false)
	_refresh()
	collapsed = true
	calc_time()
	Main.instance.reload_dict.connect(_refresh)
	Main.instance.reload_settings.connect(_evaluate_corpus)
	self.mouse_entered.connect(hover_change.emit.bind(true))
	self.mouse_exited.connect(hover_change.emit.bind(false))

func _refresh():
	refresh()
	_evaluate_corpus()

func request_rewrite(clickable: bool):
	_evaluate_corpus(clickable)

func _evaluate_corpus(clickable: bool = false):
	var to_show: Array = message
	set_etc_visibility.emit(is_message_truncatable())
	if collapsed and is_message_truncatable():
		to_show = to_show.slice(0, SettingsHandler.truncate_message_size)
		to_show.append(-25)
	set_message_text(
		DictionaryHandler.signals_to_words(
			to_show,
			SettingsHandler.do_formatting,
			supports_bbcode(),
			SettingsHandler.do_bbcode,
			clickable
		)
	)

@abstract func ready()
## Called when dictionary is reloaded
@abstract func refresh()
@abstract func set_message_text(new_text: String)
@abstract func supports_bbcode()
signal hover_change(hovering: bool)
signal set_etc_visibility(visibility: bool)
