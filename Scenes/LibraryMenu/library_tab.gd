extends Control
class_name Library

@onready var name_edit: LineEdit = $Body/HBoxContainer/Editor/Header/LineEdit
@onready var words_edit: TransmissionEdit = $Body/HBoxContainer/Editor/VSplitContainer/VBoxContainer/ScrollContainer/TransmissionEdit
@onready var delete_button: ConfirmationButton = $Body/HBoxContainer/Editor/Buttons/Delete
@onready var t_preview: TransEntry = $Body/HBoxContainer/Editor/VSplitContainer/TransHolder/TransmissionEntry
@onready var debounce: Timer = $RefreshDebounce

@onready var catalog: Container = $Body/Sidebar/ScrollContainer/Catalogue
@onready var search: LineEdit = $Body/Sidebar/SearchBar
@onready var sidebar: Container = $Body/Sidebar

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
	_evaluate_transmission()

func _evaluate_transmission():
	if current_input == words_edit.text: return
	if !debounce.is_stopped(): debounce.stop()

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
	t_preview.override_transmission_label(Localizer.translate("LIBRARY_SIGNAL_COUNT", current_transmission.size()))

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
	if search.text.is_empty():
		_do_sort()
	queue_search()

func _get_name() -> String:
	var o: String = name_edit.text
	if o.is_empty():
		o = "untitled"
	return o

func _on_submit_pressed():
	_evaluate_transmission()
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

var _search_is_queued: bool = false
func queue_search(new_text: String = search.text):
	_search_is_queued = true
	_do_search.call_deferred(new_text)

func _do_sort():
	var to_sort: Array = LibraryHandler.get_all_transmissions().duplicate()
	to_sort.sort()
	for c: LibraryEntry in catalog.get_children():
		catalog.move_child(c, to_sort.find(c.trans_name))

func _do_search(new_text: String):
	if not _search_is_queued:
		return
	_search_is_queued = false
	if new_text.is_empty():
		for c in catalog.get_children():
			c.show()
		_do_sort()
		return
	var best_candidates: Array[String] = AutocompleteManager.get_dl_candidates(
		new_text, catalog.get_children().map(func (a: LibraryEntry): return a.trans_name), 10
	)
	for c: LibraryEntry in catalog.get_children():
		if c.trans_name in best_candidates:
			c.show()
			catalog.move_child(c, best_candidates.find(c.trans_name))
		else:
			c.hide()

func _on_search_bar_text_changed(new_text: String):
	queue_search(new_text)

func _on_collapse_sidebar_toggled(toggled_on: bool):
	sidebar.visible = toggled_on
