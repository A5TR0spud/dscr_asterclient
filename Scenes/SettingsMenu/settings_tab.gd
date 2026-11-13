extends VBoxContainer

@onready var parent: VBoxContainer = $ScrollContainer/Options

func _ready() -> void:
	for c in parent.get_children():
		if c is FoldableContainer:
			c.folded = true
	$ScrollContainer.scroll_vertical = 0
	Main.instance.reload_settings.connect(refresh)
	Main.instance.reload_dictionary_support.connect(_refresh_dict_supports)
	Main.instance.reload_dict.connect(_refresh_confetti)

@export_subgroup("Signal Display")
@export var formatting: SettingEntry
@export var do_bbcode: SettingEntry
@export var color_ref_group: Control
@export var color_ref: OptionButton
@export var truncate: SpinBox
@export var font_size: SpinBox
@export var undef_setting: SettingEntry
@export_subgroup("Interface")
@export var number_sep_setting: SettingEntry
@export var right_sidebar: SettingEntry
@export var parsebar: SettingEntry
@export var pipe_escape: SettingEntry
@export var confetti_setting: SettingEntry
@export var ui_stretch: SettingEntry
@export var ui_scale: SpinBox
@export var color_edit: SpinBox
@export var color_sample: ColorRect
@export_subgroup("Sounds")
@export var sound_slider: Range
@export var music_slider: Range
@export var sound_sample: AudioStreamPlayer
@export var music_sample: AudioStreamPlayer
@export var music_parent: Control
@export var ping_slider: Range
@export_subgroup("Image")
@export var default_image_visible: SettingEntry
@export var crunch_image: SettingEntry
@export var invert_pitch: SettingEntry
@export var invert_yaw: SettingEntry
@export var invert_zoom: SettingEntry
@export var image_setting_group: FoldableContainer
@export_subgroup("")
@export var callsign_backup: CallsignSelector
@export var callsign_failsafe: BoolButton

func refresh() -> void:
	formatting.set_state_no_signal(SettingsHandler.do_formatting)
	default_image_visible.set_state_no_signal(SettingsHandler.image_default)
	do_bbcode.set_state_no_signal(SettingsHandler.do_bbcode)
	color_ref.selected = SettingsHandler.color_signal_mode
	invert_pitch.set_state_no_signal(SettingsHandler.img_invert_pitch)
	invert_yaw.set_state_no_signal(SettingsHandler.img_invert_yaw)
	invert_zoom.set_state_no_signal(SettingsHandler.img_invert_zoom)
	truncate.set_value_no_signal(SettingsHandler.truncate_message_size)
	font_size.set_value_no_signal(SettingsHandler.font_size)
	ui_stretch.set_state_no_signal(SettingsHandler.stretch_canvas)
	color_edit.set_value_no_signal(SettingsHandler.theme_color)
	sound_slider.set_value_no_signal(_volume_linear_to_slider(sound_slider, SettingsHandler.master_volume))
	music_slider.set_value_no_signal(_volume_linear_to_slider(music_slider, SettingsHandler.music_volume))
	_sample_color()
	undef_setting.set_state_no_signal(SettingsHandler.use_at_undef)
	confetti_setting.set_state_no_signal(SettingsHandler.confetti)
	number_sep_setting.set_state_no_signal(SettingsHandler.number_auto_sep)
	callsign_backup.callsign = SettingsHandler.backup_callsign
	callsign_failsafe.set_pressed_no_signal(SettingsHandler.failsafe_callsign_increment)
	_refresh_dict_supports()
	ui_scale.set_value_no_signal(SettingsHandler.stretch_scale)
	right_sidebar.set_state_no_signal(SettingsHandler.right_handed_sidebar)
	crunch_image.set_state_no_signal(SettingsHandler.crunch_image)
	parsebar.set_state_no_signal(SettingsHandler.do_parsebar)
	pipe_escape.set_state_no_signal(SettingsHandler.require_pipe_escape)

func _refresh_dict_supports():
	_refresh_confetti()
	image_setting_group.visible = DictionaryHandler.support_m0
	music_parent.visible = DictionaryHandler.support_dscr
	number_sep_setting.visible = DictionaryHandler.support_m0
	_refresh_color_ref()

func _refresh_color_ref():
	color_ref_group.visible = DictionaryHandler.support_m0
	color_ref.set_item_disabled(1, not SettingsHandler.do_bbcode)
	if color_ref.is_item_disabled(1) and color_ref.selected == 1:
		color_ref.select(2)

func _refresh_confetti():
	confetti_setting.visible = DictionaryHandler.support_dscr and -702 in DictionaryHandler.word_keys

func _volume_linear_to_slider(slider: Range, value: float) -> float:
	if value < 0:
		value = 0
	value *= 0.5 * (slider.max_value - slider.page)
	return value

func _volume_slider_to_linear(slider: Range, value: float = -1) -> float:
	if value < 0:
		value = slider.value
	value /= slider.max_value - slider.page
	value *= 2
	return value

var queued_save: bool = false
var queued_reload: bool = false

func save(requires_reload: bool, spammy: bool = false) -> void:
	if spammy:
		queued_save = true
		queued_reload = requires_reload or queued_reload
		return
	SettingsHandler.save()
	if requires_reload:
		Main.on_settings_reload()
	queued_reload = false
	queued_save = false

var count: int = 0
func _physics_process(_delta):
	if count >= 5:
		if queued_save:
			save(queued_reload)
		count = -1
	count += 1

func _on_formatting_set(new_value):
	SettingsHandler.do_formatting = new_value
	save(true)

func _on_image_vis_set(new_value):
	SettingsHandler.image_default = new_value
	save(false)

func _on_do_bb_code_set(new_value):
	SettingsHandler.do_bbcode = new_value
	Main.on_dict_reload()
	_refresh_color_ref()
	save(false)

func _on_truncation_spinner_value_changed(value):
	SettingsHandler.truncate_message_size = roundi(value)
	save(true, true)

func _on_font_spinner_value_changed(value):
	SettingsHandler.font_size = value
	save(true, true)

func _sample_color(val: int = -1):
	if val < 0 or val > 64:
		val = roundi(color_edit.value)
	color_sample.color = VisualizeNode.calculate_color(val)

func _on_color_submit_button_pressed():
	ThemeManager.set_theme_color(roundi(color_edit.value))

func _on_color_cancel_button_pressed():
	color_edit.value = SettingsHandler.theme_color
	_sample_color()

func _on_color_picker_value_changed(value):
	_sample_color(value)

func _on_volume_slider_value_changed(value):
	SettingsHandler.master_volume = _volume_slider_to_linear(sound_slider, value)
	SettingsHandler.evaluate_volume()
	if not sound_sample.playing:
		sound_sample.play()
	save(false, true)

func _on_music_slider_value_changed(value):
	SettingsHandler.music_volume = _volume_slider_to_linear(music_slider, value)
	SettingsHandler.evaluate_volume()
	if not music_sample.playing:
		music_sample.play()
	save(false, true)

func _on_invert_pitch_set(new_value):
	SettingsHandler.img_invert_pitch = new_value
	Main.on_image_inversion_reload()
	save(false)

func _on_invert_yaw_set(new_value):
	SettingsHandler.img_invert_yaw = new_value
	Main.on_image_inversion_reload()
	save(false)

func _on_invert_zoom_set(new_value):
	SettingsHandler.img_invert_zoom = new_value
	Main.on_image_inversion_reload()
	save(false)

func _on_undef_setting_set(new_value):
	SettingsHandler.use_at_undef = new_value
	Main.on_dict_reload()
	save(false)

func _on_confetti_set(new_value):
	SettingsHandler.confetti = new_value
	save(false)

func _on_number_separation_set(new_value):
	SettingsHandler.number_auto_sep = new_value
	save(false)

func _on_volume_normal_pressed():
	sound_slider.value = _volume_linear_to_slider(sound_slider, 1)

func _on_music_volume_normal_pressed():
	music_slider.value = _volume_linear_to_slider(music_slider, 1)

func _on_callsign_node_callsign_submitted(new_value):
	SettingsHandler.backup_callsign = new_value
	save(false)

func _on_backup_backup_mode_toggled(toggled_on):
	SettingsHandler.failsafe_callsign_increment = toggled_on
	save(false)

func _on_ui_stretch_set(new_value):
	SettingsHandler.stretch_canvas = new_value
	SettingsHandler.stretch_or_unstretch_canvas()
	save(false)

func _on_scale_confirm_cancel():
	SettingsHandler.stretch_or_unstretch_canvas()
	ui_scale.editable = true
	ui_scale.set_value_no_signal(SettingsHandler.stretch_scale)

func _on_scale_confirm_confirmed():
	SettingsHandler.stretch_scale = ui_scale.value
	SettingsHandler.stretch_or_unstretch_canvas()
	save(false)
	ui_scale.editable = true

func _on_scale_confirm_probed():
	ui_scale.editable = false
	SettingsHandler.apply_ui_scale(ui_scale.value)

func _on_color_ref_switch_item_selected(index: int):
	SettingsHandler.color_signal_mode = index
	Main.on_dictionary_support_updated()
	save(false)

func _on_rh_sidebar_set(new_value):
	SettingsHandler.right_handed_sidebar = new_value
	save(true)

func _on_crunch_image_set(new_value):
	SettingsHandler.crunch_image = new_value
	save(true)

func _on_ping_volume_normal_pressed():
	ping_slider.value = _volume_linear_to_slider(ping_slider, 1)

func _on_ping_volume_slider_value_changed(value):
	SettingsHandler.ping_volume = _volume_slider_to_linear(ping_slider, value)
	SettingsHandler.evaluate_volume()
	SoundManager.play_sound(SoundManager.Sounds.PING, true)
	save(false, true)

func _on_parsebar_set(new_value):
	SettingsHandler.do_parsebar = new_value
	save(true)

func _on_pipe_escape_setting_set(new_value):
	SettingsHandler.require_pipe_escape = new_value
	save(true)
