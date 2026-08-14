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

func _ready():
	Main.instance.reload_dict.connect(refresh)
	hide()

func save() -> void:
	if current_signal == 0:
		DictionaryHandler.default_before_mode = before_label.selected
		DictionaryHandler.default_after_mode = after_label.selected
		SaveSystem.save_dict()
		Main.on_dict_reload()
		return
	if not DictionaryHandler.apply_signal_name(current_signal, name_edit.text, true):
		return
	name_label.text = DictionaryHandler.get_or_default_signal_name(current_signal)
	DictionaryHandler.apply_signal_desc(current_signal, {
		DictionaryHandler.desc_key: desc_edit.text,
		DictionaryHandler.before_key: before_label.selected,
		DictionaryHandler.after_key: after_label.selected,
		DictionaryHandler.break_key: break_button.is_on
	})
	SaveSystem.save_dict()
	Main.on_dict_reload()

func reload() -> void:
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
	break_button.is_on = desc[DictionaryHandler.break_key]

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

func _input(event: InputEvent):
	if event.is_action_pressed("ui_close_dialog"):
		hide()
	if event.is_action_pressed("ui_text_submit") and not event.is_action_pressed("ui_text_newline"):
		save()

func _on_submit_button_pressed():
	save()
	#hide()

func _on_cancel_button_pressed():
	reload()

func _on_close_button_pressed():
	hide()

func _on_delete_button_pressed():
	DictionaryHandler.forget_signal(current_signal)
	Main.on_dict_reload()
	SaveSystem.save_dict()
	hide()

func _on_name_line_edit_text_submitted(_new_text):
	save()

func _on_name_line_edit_text_changed(new_text):
	var col := name_edit.caret_column
	name_edit.text = DictionaryHandler.filter_name_input(new_text)
	name_edit.caret_column = col
