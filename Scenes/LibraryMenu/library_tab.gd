extends Control
class_name Library

@onready var name_edit: LineEdit = $Body/Editor/Header/LineEdit
@onready var words_edit: TransmissionEdit = $Body/Editor/GridContainer/VBoxContainer/ScrollContainer/TransmissionEdit
@onready var delete_button: ConfirmationButton = $Body/Editor/Buttons/Delete
@onready var t_preview: TransEntry = $Body/Editor/GridContainer/TransHolder/TransmissionEntry
@onready var debounce: Timer = $RefreshDebounce

@onready var catalog: Control = $Body/ScrollContainer/MarginContainer/Catalogue

var lib_entry = preload("res://Scenes/LibraryMenu/library_entry.tscn")

var pre_name: String = ""
var current_input: String = ""
var current_transmission: Array = []
var unsaved_changes: bool = false

static var instance: Library

func _enter_tree():
	instance = self

static func open_transmission(trx: String):
	instance.pre_name = trx
	instance.name_edit.text = trx
	instance.current_transmission = LibraryHandler.get_transmission(trx)
	instance._reload()
	instance.current_input = instance.words_edit.text

func _on_transmission_edit_text_changed():
	debounce.stop()
	debounce.start()

func _on_refresh_debounce_timeout():
	if current_input == words_edit.text: return

	var parsed: ParseResult = DictionaryHandler.parse_text(words_edit.text, false)
	if current_transmission != parsed.output:
		current_input = words_edit.text
		current_transmission = parsed.output
		_set_sig_text()
	unsaved_changes = true

func _set_sig_text():
	t_preview.message = current_transmission
	t_preview.request_rewrite(false)
	t_preview.try_parses()
	t_preview.override_transmission_label(DictionaryHandler.signals_to_words([-42, -23, -4, current_transmission.size()]))

func _ready():
	Main.instance.reload_dict.connect(_reload)
	Main.instance.reload_library.connect(_reload)
	Main.instance.reload_nicknames.connect(_refresh_preview)
	Main.instance.on_callsign_changed.connect(func (_a): _refresh_preview())

func _refresh_preview():
	t_preview.refresh()
	t_preview.sender = Main.instance.previously_accepted_callsign
	t_preview.refresh_callsign()
	_set_sig_text()

func _reload():
	_set_sig_text()
	delete_button.set_confirm_state(false)
	words_edit.text = DictionaryHandler.signals_to_words(current_transmission, true)
	_refresh_preview()
	var known: Array[String] = []
	for idx in range(catalog.get_child_count()):
		var c = catalog.get_child(idx)
		if c is not LibraryEntry:
			continue
		c = c as LibraryEntry
		if c.trans_name not in LibraryHandler.get_all_transmissions():
			c.queue_free()
		else:
			known.append(c.trans_name)
	for s in LibraryHandler.get_all_transmissions():
		if s not in known:
			var c: LibraryEntry = lib_entry.instantiate()
			c.trans_name = s
			catalog.add_child(c)

func _get_name() -> String:
	var o: String = name_edit.text
	if o.is_empty():
		o = "untitled"
	return o

func _on_submit_pressed():
	LibraryHandler.set_transmission(_get_name(), current_transmission)
	_reload()
	unsaved_changes = false

func _on_cancel_pressed():
	name_edit.text = pre_name
	current_transmission = LibraryHandler.get_transmission(pre_name)
	_reload()
	unsaved_changes = false

func _on_delete_confirmed():
	LibraryHandler.forget_transmission(_get_name())
	name_edit.text = ""
	words_edit.text = ""
	current_transmission = []
	unsaved_changes = false
	_reload()

func _on_copy_signals_pressed():
	var o: Array[String] = []
	for sig in current_transmission:
		var s: String = "|" if sig < 0 else ""
		s += str(sig)
		o.append(s)
	DisplayServer.clipboard_set(" ".join(o))

func _on_copy_words_pressed():
	DisplayServer.clipboard_set(DictionaryHandler.signals_to_words(current_transmission, true))

func _on_visibility_changed():
	if visible:
		_refresh_preview()
