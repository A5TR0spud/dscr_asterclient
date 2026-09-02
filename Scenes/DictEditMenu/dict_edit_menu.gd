extends Container
class_name DictEditMenu

static var instance: DictEditMenu

func _enter_tree():
	instance = self

@export var current_signal: int = 0

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
@onready var delete_button: ConfirmationButton = $DictEditMainframe/SubmitElseCancel/DeleteButton

@onready var indentation: Control = $DictEditMainframe/Indentation
@onready var indent_option: OptionButton = $DictEditMainframe/Indentation/IndentOption

@onready var bbcode_options: Control = $DictEditMainframe/BBCodeOptions
@onready var bold_edit: BoolButton = $DictEditMainframe/BBCodeOptions/GridContainer/Bold/Button
@onready var italic_edit: BoolButton = $DictEditMainframe/BBCodeOptions/GridContainer/Italic/Button
@onready var underline_edit: BoolButton = $DictEditMainframe/BBCodeOptions/GridContainer/Underline/Button
@onready var strikethrough_edit: BoolButton = $DictEditMainframe/BBCodeOptions/GridContainer/Strikethrough/Button
@onready var background_edit: BoolButton = $DictEditMainframe/BBCodeOptions/ColorPicker/BG

@onready var hue: SpinBox = $DictEditMainframe/BBCodeOptions/ColorPicker/GridContainer/HueSpinner
@onready var val: SpinBox = $DictEditMainframe/BBCodeOptions/ColorPicker/GridContainer/ValueSpinner
@onready var sat: SpinBox = $DictEditMainframe/BBCodeOptions/ColorPicker/GridContainer/SatSpinner
@onready var hue_rect: ColorRect = $DictEditMainframe/BBCodeOptions/ColorPicker/GridContainer/HueColor
@onready var val_rect: ColorRect = $DictEditMainframe/BBCodeOptions/ColorPicker/GridContainer/ValueColor
@onready var sat_rect: ColorRect = $DictEditMainframe/BBCodeOptions/ColorPicker/GridContainer/SatColor
@onready var prv_rect: ColorRect = $DictEditMainframe/BBCodeOptions/ColorPicker/PreviewColor

func _ready():
	Main.instance.reload_dict.connect(refresh)
	hide()

const UNKNOWN_SIGNAL: int = 0

func save() -> void:
	if current_signal == UNKNOWN_SIGNAL:
		DictionaryHandler.default_before_mode = before_label.selected
		DictionaryHandler.default_after_mode = after_label.selected
		DictionaryHandler.default_color = "#"+_get_spinners_as_color().to_html(false)
		DictionaryHandler.default_bold = bold_edit.button_pressed
		DictionaryHandler.default_italic = italic_edit.button_pressed
		DictionaryHandler.default_underline = underline_edit.button_pressed
		DictionaryHandler.default_italic = italic_edit.button_pressed
		DictionaryHandler.default_background = background_edit.button_pressed
		SoundManager.play_sound(SoundManager.Sounds.CONFIRMED)
		SaveSystem.save_dict()
		Main.on_dict_reload()
		return
	if not DictionaryHandler.apply_signal_name(current_signal, name_edit.text, true):
		SoundManager.play_sound(SoundManager.Sounds.FAIL)
		return
	SoundManager.play_sound(SoundManager.Sounds.CONFIRMED)
	name_label.text = DictionaryHandler.get_or_default_signal_name(current_signal)
	var desc: Dictionary = {
		DictionaryHandler.desc_key: desc_edit.text,
		DictionaryHandler.break_key: break_button.button_pressed
	}
	if before_label.selected < 4:
		desc.set(DictionaryHandler.before_key, before_label.selected)
		desc.set(DictionaryHandler.extra_before_key, 0)
	else:
		desc.set(DictionaryHandler.before_key, 0)
		desc.set(DictionaryHandler.extra_before_key, before_label.selected - 3)
	if after_label.selected < 4:
		desc.set(DictionaryHandler.after_key, after_label.selected)
		desc.set(DictionaryHandler.extra_after_key, 0)
	else:
		desc.set(DictionaryHandler.after_key, 0)
		desc.set(DictionaryHandler.extra_after_key, after_label.selected - 3)
	
	desc.set(DictionaryHandler.color_key, "#"+_get_spinners_as_color().to_html(false))
	desc.set(DictionaryHandler.bold_key, bold_edit.button_pressed)
	desc.set(DictionaryHandler.italic_key, italic_edit.button_pressed)
	desc.set(DictionaryHandler.underline_key, underline_edit.button_pressed)
	desc.set(DictionaryHandler.strikethrough_key, strikethrough_edit.button_pressed)
	desc.set(DictionaryHandler.background_key, background_edit.button_pressed)
	if indent_option.selected != 0:
		desc.set(DictionaryHandler.indent_key, 1 if indent_option.selected == 1 else -1)
	DictionaryHandler.apply_signal_desc(current_signal, desc)
	SaveSystem.save_dict()
	Main.on_dict_reload()

func reload() -> void:
	break_sentence.visible = current_signal < 0
	name_sentence.visible = current_signal < 0
	desc_edit.visible = current_signal < 0
	delete_button.visible = current_signal < 0
	bbcode_options.visible = SettingsHandler.do_bbcode
	indentation.visible = current_signal < 0
	before_label.set_item_disabled(4, current_signal >= 0)
	after_label.set_item_disabled(4, current_signal >= 0)
	if current_signal == UNKNOWN_SIGNAL:
		before_after_clear_label.text = DictionaryHandler.signals_to_words([-122, -42, -122])
		before_label.select(DictionaryHandler.default_before_mode)
		after_label.select(DictionaryHandler.default_after_mode)
		_push_color_to_spinners(Color.from_string(DictionaryHandler.default_color, Color.WHITE))
		bold_edit.button_pressed = DictionaryHandler.default_bold
		italic_edit.button_pressed = DictionaryHandler.default_italic
		underline_edit.button_pressed = DictionaryHandler.default_underline
		strikethrough_edit.button_pressed = DictionaryHandler.default_strikethrough
		background_edit.button_pressed = DictionaryHandler.default_background
		return
	var desc: Dictionary = DictionaryHandler.get_or_default_signal_desc(current_signal)
	name_label.text = DictionaryHandler.signals_to_words([-42, -14, -1, absi(current_signal), -15, -4])
	before_after_clear_label.text = DictionaryHandler.signals_to_words([-122, current_signal, -122])
	name_edit.text = DictionaryHandler.get_or_default_signal_name(current_signal)
	if not DictionaryHandler.word_keys.has(current_signal):
		name_edit.grab_focus()
		name_edit.select_all()
	desc_edit.text = desc[DictionaryHandler.desc_key]
	var tmp0: int = desc[DictionaryHandler.before_key]
	var tmp1: int = desc.get(DictionaryHandler.extra_before_key, 0)
	if tmp1 > 0:
		before_label.select(tmp1 + 3)
	else:
		before_label.select(tmp0)
	tmp0 = desc[DictionaryHandler.after_key]
	tmp1 = desc.get(DictionaryHandler.extra_after_key, 0)
	if tmp1 > 0:
		after_label.select(tmp1 + 3)
	else:
		after_label.select(tmp0)
	break_button.set_pressed_no_signal(desc[DictionaryHandler.break_key])
	break_button.refresh()
	delete_button.set_confirm_state(false)
	delete_button.disabled = not DictionaryHandler.word_keys.has(current_signal)
	
	var indent_format: int = int(desc.get(DictionaryHandler.indent_key, 0))
	if indent_format == 0:
		indent_option.select(0)
	elif indent_format > 0:
		indent_option.select(1)
	else:
		indent_option.select(2)
	
	var b_value: bool = desc.get(DictionaryHandler.bold_key, false)
	bold_edit.button_pressed = b_value
	var i_value: bool = desc.get(DictionaryHandler.italic_key, false)
	italic_edit.button_pressed = i_value
	var s_value: bool = desc.get(DictionaryHandler.strikethrough_key, false)
	strikethrough_edit.button_pressed = s_value
	var u_value: bool = desc.get(DictionaryHandler.underline_key, false)
	underline_edit.button_pressed = u_value
	var bg_value: bool = desc.get(DictionaryHandler.background_key, false)
	background_edit.button_pressed = bg_value
	
	var color_value = desc.get(DictionaryHandler.color_key, 64)
	if color_value is int or color_value is float:
		color_value = VisualizeNode.calculate_color(color_value as int)
	elif color_value is String:
		color_value = Color.from_string(color_value as String, Color.WHITE)
	_push_color_to_spinners(color_value as Color)
	#_sample_color(int(color_edit.value))

func _get_spinners_as_color() -> Color:
	var H: float = hue.value
	if H <= 8.5:
		H = remap(H, 0, 8, 0, 10)
	elif H <= 13.5:
		H = remap(H, 8, 13, 10, 21)
	elif H <= 25.5:
		H = remap(H, 13, 25, 21, 25)
	var h: float = H / 40.0
	var s: float = (50 - sat.value) * 0.1
	var v: float = (val.value - 50) / 14.0
	return Color.from_hsv(h, s, v)

func _push_color_to_spinners(col: Color):
	var h: float = col.h * 40
	if h <= 10.5:
		h = remap(h, 0, 10, 0, 8)
	elif h <= 21.5:
		h = remap(h, 10, 21, 8, 13)
	elif h <= 25.5:
		h = remap(h, 21, 25, 13, 25)
	hue.value = h
	sat.value = 50 - col.s * 10
	val.value = col.v * 14 + 50

func refresh():
	reload()
	before_label.set_item_text(0, DictionaryHandler.signals_to_words([-111]))
	before_label.set_item_text(1, DictionaryHandler.signals_to_words([1, -190]))
	before_label.set_item_text(2, DictionaryHandler.signals_to_words([1, -108, -190]))
	before_label.set_item_text(3, DictionaryHandler.signals_to_words([2, -108, -190]))
	before_label.set_item_text(4, DictionaryHandler.signals_to_words([1, -189]))
	after_label.set_item_text(0, DictionaryHandler.signals_to_words([-111]))
	after_label.set_item_text(1, DictionaryHandler.signals_to_words([1, -190]))
	after_label.set_item_text(2, DictionaryHandler.signals_to_words([1, -108, -190]))
	after_label.set_item_text(3, DictionaryHandler.signals_to_words([2, -108, -190]))
	after_label.set_item_text(4, DictionaryHandler.signals_to_words([1, -189]))

func _on_notes_edit_gui_input(event):
	if event.is_action_pressed("ui_text_submit") and not event.is_action_pressed("ui_text_newline"):
		save()
		accept_event()

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_close_dialog"):
		close()
		accept_event()

static func is_open() -> bool:
	return instance.visible

static func open(sig: int = 0, repeat_to_close: bool = false) -> void:
	if instance.current_signal == sig and repeat_to_close and is_open():
		close()
		return
	instance.current_signal = sig
	instance.grab_click_focus()
	instance.reload()
	instance.show()

static func close():
	instance.delete_button.set_confirm_state(false)
	instance.hide()

static func select_signal_name():
	instance.name_edit.grab_focus()
	instance.name_edit.select_all()

func _on_submit_button_pressed():
	save()
	#hide()

func _on_cancel_button_pressed():
	SoundManager.play_sound(SoundManager.Sounds.DISCARD)
	reload()

func _on_close_button_pressed():
	close()



func _on_name_line_edit_text_submitted(_new_text):
	save()

func _sample_color():
	var h: int = roundi(hue.value)
	var s: int = roundi(sat.value)
	var v: int = roundi(val.value)
	hue_rect.color = VisualizeNode.calculate_color(h)
	sat_rect.color = VisualizeNode.calculate_color(s)
	val_rect.color = VisualizeNode.calculate_color(v)
	prv_rect.color = _get_spinners_as_color()

func _on_hue_spinner_value_changed(_value):
	_sample_color()

func _on_value_spinner_value_changed(_value):
	_sample_color()

func _on_sat_spinner_value_changed(_value):
	_sample_color()

func _on_delete_button_confirmed():
	DictionaryHandler.forget_signal(current_signal)
	Main.on_dict_reload()
	SaveSystem.save_dict()
	close()
