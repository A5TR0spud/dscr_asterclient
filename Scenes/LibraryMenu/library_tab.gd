extends Control
class_name Library

@onready var name_edit: LineEdit = $Body/Editor/Header/LineEdit
@onready var signals_display: RichTextLabel = $Body/Editor/GridContainer/TabContainer/SignalDisplay
@onready var words_edit: TransmissionEdit = $Body/Editor/GridContainer/VBoxContainer/ScrollContainer/TransmissionEdit
@onready var delete_button: ConfirmationButton = $Body/Editor/Buttons/Delete
@onready var tabber: TabContainer = $Body/Editor/GridContainer/TabContainer
@onready var t_holder: Control = $Body/Editor/GridContainer/TabContainer/TransHolder
@onready var signal_count: Label = $Body/Editor/GridContainer/VBoxContainer/SignalCount

@onready var catalog: Control = $Body/ScrollContainer/MarginContainer/Catalogue

var trans_entry = preload("res://Scenes/ChatMenu/transmission_entry.tscn")
var lib_entry = preload("res://Scenes/LibraryMenu/library_entry.tscn")

var pre_name: String = ""
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

func _on_transmission_edit_text_changed():
	var parsed: ParseResult = DictionaryHandler.parse_text(words_edit.text, false)
	if current_transmission != parsed.output:
		current_transmission = parsed.output
		_set_sig_text()
	unsaved_changes = true

func _set_sig_text():
	var o: Array[String] = []
	for sig in current_transmission:
		var s: String = "|" if sig < 0 else ""
		s += str(sig)
		o.append(s)
	signals_display.text = " ".join(o)
	signal_count.text = DictionaryHandler.signals_to_words([-42, -23, -4, current_transmission.size()])
	_hard_refresh_transmission()

func _ready():
	Main.instance.reload_dict.connect(_reload)
	Main.instance.reload_library.connect(_reload)
	tabber.current_tab = 0

func _hard_refresh_transmission():
	for c in t_holder.get_children():
		if c is TransEntry:
			c.queue_free()
	var new: TransEntry = trans_entry.instantiate()
	new.message = current_transmission
	new.sender = Main.instance.previously_accepted_callsign
	new.timestamp = Time.get_ticks_msec()
	t_holder.add_child(new)

func _reload():
	_set_sig_text()
	delete_button.set_confirm_state(false)
	words_edit.text = DictionaryHandler.signals_to_words(current_transmission, true)
	tabber.set_tab_title(0, DictionaryHandler.get_or_default_signal_name(-42))
	tabber.set_tab_title(1, DictionaryHandler.get_or_default_signal_name(-163))
	_hard_refresh_transmission()
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
	signals_display.text = ""
	current_transmission = []
	unsaved_changes = false
	_reload()

func _on_copy_signals_pressed():
	DisplayServer.clipboard_set(signals_display.text)

func _on_copy_words_pressed():
	DisplayServer.clipboard_set(DictionaryHandler.signals_to_words(current_transmission, true))

func _on_tab_container_tab_changed(tab):
	if tab == 1:
		_hard_refresh_transmission()
