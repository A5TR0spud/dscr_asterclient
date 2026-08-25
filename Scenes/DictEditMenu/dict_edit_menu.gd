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
@onready var delete_button: Button = $DictEditMainframe/SubmitElseCancel/DeleteButton
@onready var delete_confirm: bool = false
@onready var delete_time_window: Timer = $DeleteConfirm

@onready var bbcode_options: Control = $DictEditMainframe/BBCodeOptions
@onready var underline_parent: Control = $DictEditMainframe/BBCodeOptions/UnderlineSentence
@onready var underline_edit: Button = $DictEditMainframe/BBCodeOptions/UnderlineSentence/DoUnderlineButton

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

func save() -> void:
	if current_signal == 0:
		DictionaryHandler.default_before_mode = before_label.selected
		DictionaryHandler.default_after_mode = after_label.selected
		DictionaryHandler.default_color = _get_spinners_as_color().to_html(false)
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
		DictionaryHandler.before_key: before_label.selected,
		DictionaryHandler.after_key: after_label.selected,
		DictionaryHandler.break_key: break_button.button_pressed
	}
	if SettingsHandler.do_bbcode:
		if "ffffff" not in _get_spinners_as_color().to_html(false):
			desc.set(DictionaryHandler.color_key, "#"+_get_spinners_as_color().to_html(false))
		if underline_edit.button_pressed:
			desc.set(DictionaryHandler.underline_key, true)
	DictionaryHandler.apply_signal_desc(current_signal, desc)
	SaveSystem.save_dict()
	Main.on_dict_reload()

func reload() -> void:
	delete_confirm = false
	break_sentence.visible = current_signal < 0
	name_sentence.visible = current_signal < 0
	desc_edit.visible = current_signal < 0
	delete_button.visible = current_signal < 0
	bbcode_options.visible = SettingsHandler.do_bbcode
	underline_parent.visible = current_signal != 0
	if current_signal == 0:
		before_after_clear_label.text = DictionaryHandler.signals_to_words([-122, -42, -122])
		before_label.select(DictionaryHandler.default_before_mode)
		after_label.select(DictionaryHandler.default_after_mode)
		_push_color_to_spinners(Color.from_string(DictionaryHandler.default_color, Color.WHITE))
		return
	var desc: Dictionary = DictionaryHandler.get_or_default_signal_desc(current_signal)
	name_label.text = DictionaryHandler.signals_to_words([-42, -14, -1, absi(current_signal), -15, -4])
	before_after_clear_label.text = DictionaryHandler.signals_to_words([-122, current_signal, -122])
	name_edit.text = DictionaryHandler.get_or_default_signal_name(current_signal)
	if not DictionaryHandler.word_keys.has(current_signal):
		name_edit.grab_focus()
		name_edit.select_all()
	desc_edit.text = desc[DictionaryHandler.desc_key]
	before_label.select(int(desc[DictionaryHandler.before_key]))
	after_label.select(int(desc[DictionaryHandler.after_key]))
	break_button.set_pressed_no_signal(desc[DictionaryHandler.break_key])
	break_button.refresh()
	_set_delete_button_state(false)
	delete_button.disabled = not DictionaryHandler.word_keys.has(current_signal)
	var underline_value: bool = desc.get(DictionaryHandler.underline_key, false)

	underline_edit.set_pressed_no_signal(underline_value)
	underline_edit.refresh()
	
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
		close()
		accept_event()

static func is_open() -> bool:
	return instance.visible

static func open(sig: int = 0, repeat_to_close: bool = false) -> void:
	if instance.current_signal == sig and repeat_to_close and is_open():
		close()
		return
	instance.current_signal = sig
	instance.reload()
	instance.show()

static func close():
	instance._set_delete_button_state(false)
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
	SoundManager.play_sound(SoundManager.Sounds.CLICK)
	close()

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
		close()
	else:
		SoundManager.play_sound(SoundManager.Sounds.COMMAND_ACCEPTED)
		_set_delete_button_state(true)
		delete_button.disabled = true
		get_tree().create_timer(Main.HE6_HALF_LIFE * 0.5).timeout.connect(func(): delete_button.disabled = false)

func _on_name_line_edit_text_submitted(_new_text):
	save()

func _on_delete_confirm_timeout():
	_set_delete_button_state(false)

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
