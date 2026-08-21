extends Container
class_name DictEditMenu

static var instance: DictEditMenu

func _enter_tree():
	instance = self

@export var current_signal: int = 0:
	set(value):
		current_signal = min(value, 0)
		reload()

# TODO: rename these. PascalCase is :(
@onready var name_label: Label = $DictEditMainframe/SignalNameEdit/NameLabel
@onready var before_label: OptionButton = $DictEditMainframe/BeforeAndAfterFormat/BeforeOption
@onready var before_after_clear_label: Label = $DictEditMainframe/BeforeAndAfterFormat/FormatClarity
@onready var after_label: OptionButton = $DictEditMainframe/BeforeAndAfterFormat/AfterOption
@onready var break_button: BoolButton = $DictEditMainframe/BreakSentence/BreakOnDouble

@onready var name_edit: LineEdit = $DictEditMainframe/SignalNameEdit/NameLineEdit
@onready var desc_edit: TextEdit = $DictEditMainframe/NotesEdit

@onready var break_sentence: HBoxContainer = $DictEditMainframe/BreakSentence
@onready var name_sentence: HBoxContainer = $DictEditMainframe/SignalNameEdit
@onready var delete_button: Button = $DictEditMainframe/SubmitElseCancel/DeleteButton

@onready var delete_confirm: bool = false
@onready var delete_time_window: Timer = $DeleteConfirm

func _ready():
	Main.instance.reload_dict.connect(refresh)
	hide()

func save() -> void:
	if current_signal == 0:
		DictionaryHandler.default_before_mode = before_label.selected
		DictionaryHandler.default_after_mode = after_label.selected
		SoundManager.play_sound(SoundManager.Sounds.CONFIRMED)
		SaveSystem.save_dict()
		Main.on_dict_reload()
		return
	if not DictionaryHandler.apply_signal_name(current_signal, name_edit.text, true):
		SoundManager.play_sound(SoundManager.Sounds.FAIL)
		return
	SoundManager.play_sound(SoundManager.Sounds.CONFIRMED)
	name_label.text = DictionaryHandler.get_or_default_signal_name(current_signal)
	DictionaryHandler.apply_signal_desc(current_signal, {
		DictionaryHandler.desc_key: desc_edit.text,
		DictionaryHandler.before_key: before_label.selected,
		DictionaryHandler.after_key: after_label.selected,
		DictionaryHandler.break_key: break_button.button_pressed
	})
	SaveSystem.save_dict()
	Main.on_dict_reload()

func reload() -> void:
	delete_confirm = false
	break_sentence.visible = current_signal != 0
	name_sentence.visible = current_signal != 0
	desc_edit.visible = current_signal != 0
	delete_button.visible = current_signal != 0
	if current_signal == 0:
		before_after_clear_label.text = DictionaryHandler.signals_to_words([-122, -124, -42, -122])
		before_label.select(DictionaryHandler.default_before_mode)
		after_label.select(DictionaryHandler.default_after_mode)
		return
	var desc: Dictionary = DictionaryHandler.get_or_default_signal_desc(current_signal)
	name_label.text = DictionaryHandler.signals_to_words([-42, -14, -1, absi(current_signal), -15, -4])
	before_after_clear_label.text = DictionaryHandler.signals_to_words([-122, current_signal, -122])
	name_edit.text = DictionaryHandler.get_or_default_signal_name(current_signal)
	desc_edit.text = desc[DictionaryHandler.desc_key]
	before_label.select(int(desc[DictionaryHandler.before_key]))
	after_label.select(int(desc[DictionaryHandler.after_key]))
	break_button.set_pressed_no_signal(desc[DictionaryHandler.break_key])
	break_button.refresh()
	_set_delete_button_state(false)
	#delete_button.remove_theme_color_override("font_color")
	#delete_button.remove_theme_color_override("font_hover_color")

func refresh():
	reload()
	before_label.set("popup/item_0/text", DictionaryHandler.signals_to_words([-111]))
	before_label.set("popup/item_1/text", DictionaryHandler.signals_to_words([1, -190]))
	before_label.set("popup/item_2/text", DictionaryHandler.signals_to_words([1, -108, -190]))
	before_label.set("popup/item_3/text", DictionaryHandler.signals_to_words([2, -108, -190]))
	after_label.set("popup/item_0/text", DictionaryHandler.signals_to_words([-111]))
	after_label.set("popup/item_1/text", DictionaryHandler.signals_to_words([1, -190]))
	after_label.set("popup/item_2/text", DictionaryHandler.signals_to_words([1, -108, -190]))
	after_label.set("popup/item_3/text", DictionaryHandler.signals_to_words([2, -108, -190]))


func _on_notes_edit_gui_input(event):
	if event.is_action_pressed("ui_text_submit") and not event.is_action_pressed("ui_text_newline"):
		save()
		accept_event()

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_close_dialog"):
		hide()
		accept_event()

func _on_submit_button_pressed():
	save()
	#hide()

func _on_cancel_button_pressed():
	SoundManager.play_sound(SoundManager.Sounds.DISCARD)
	reload()

func _on_close_button_pressed():
	SoundManager.play_sound(SoundManager.Sounds.CLICK)
	hide()
	_set_delete_button_state(false)

func _set_delete_button_state(confirmation = null) -> void:
	if confirmation is bool:
		delete_confirm = confirmation
	if delete_confirm:
		delete_button.text = DictionaryHandler.signals_to_words([-42, -88, -85])
		delete_button.self_modulate = Color(1, .4, .475)
		delete_time_window.start()
	else:
		delete_button.text = DictionaryHandler.signals_to_words([-88, -127, -85])
		delete_button.self_modulate = Color(1., 1., 1.)
		delete_time_window.stop()

func _on_delete_button_pressed():
	if delete_confirm:
		SoundManager.play_sound(SoundManager.Sounds.DISCARD)
		DictionaryHandler.forget_signal(current_signal)
		Main.on_dict_reload()
		SaveSystem.save_dict()
		hide()
	else:
		SoundManager.play_sound(SoundManager.Sounds.COMMAND_ACCEPTED)
		_set_delete_button_state(true)

func _on_name_line_edit_text_submitted(_new_text):
	save()

func _on_delete_confirm_timeout():
	_set_delete_button_state(false)
