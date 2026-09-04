extends VBoxContainer

func _ready() -> void:
	Main.instance.reload_settings.connect(refresh)

@onready var formatting: SettingEntry = $ScrollContainer/MarginContainer/Options/Formatting
@onready var image_visibility: SettingEntry = $ScrollContainer/MarginContainer/Options/ImageVis
@onready var do_bbcode: SettingEntry = $ScrollContainer/MarginContainer/Options/DoBBCode
@onready var truncate: SpinBox = $ScrollContainer/MarginContainer/Options/TruncHbox/TruncationSpinner
@onready var font_size: SpinBox = $ScrollContainer/MarginContainer/Options/FontHbox/FontSpinner
@onready var address_edit: LineEdit = $ScrollContainer/MarginContainer/Options/Address/AdressEdit
@onready var color_edit: SpinBox = $ScrollContainer/MarginContainer/Options/ThemeColor/ColorPicker
@onready var color_sample: ColorRect = $ScrollContainer/MarginContainer/Options/ColorRect
@onready var sound_slider: HScrollBar = $ScrollContainer/MarginContainer/Options/GlobalVolume/VolumeSlider
@onready var sound_sample: AudioStreamPlayer = $AudioPreview
@onready var invert_pitch: SettingEntry = $ScrollContainer/MarginContainer/Options/ImageMovement/VBoxContainer/InvertPitch
@onready var invert_yaw: SettingEntry = $ScrollContainer/MarginContainer/Options/ImageMovement/VBoxContainer/InvertYaw
@onready var invert_zoom: SettingEntry = $ScrollContainer/MarginContainer/Options/ImageMovement/VBoxContainer/InvertZoom
@onready var undef_setting: SettingEntry = $ScrollContainer/MarginContainer/Options/UndefSetting

func refresh() -> void:
	formatting.set_state_no_signal(SettingsHandler.do_formatting)
	image_visibility.set_state_no_signal(SettingsHandler.image_default)
	do_bbcode.set_state_no_signal(SettingsHandler.do_bbcode)
	invert_pitch.set_state_no_signal(SettingsHandler.img_invert_pitch)
	invert_yaw.set_state_no_signal(SettingsHandler.img_invert_yaw)
	invert_zoom.set_state_no_signal(SettingsHandler.img_invert_zoom)
	truncate.set_value_no_signal(SettingsHandler.truncate_message_size)
	font_size.set_value_no_signal(SettingsHandler.font_size)
	color_edit.set_value_no_signal(SettingsHandler.theme_color)
	sound_slider.set_value_no_signal(_volume_linear_to_slider())
	_sample_color()
	undef_setting.set_state_no_signal(SettingsHandler.use_at_undef)

func _volume_linear_to_slider(value: float = -1) -> float:
	if value < 0:
		value = SettingsHandler.master_volume
	if value > 1:
		value = (value - 1) * 2 + 1
	value *= 0.5 * (sound_slider.max_value - sound_slider.page)
	return value

func _volume_slider_to_linear(value: float = -1) -> float:
	if value < 0:
		value = sound_slider.value
	value /= sound_slider.max_value - sound_slider.page
	value *= 2
	if value > 1:
		value = 1 + (value - 1) * 0.5
	return value

var queued_save: bool = false
var queued_reload: bool = false

func save(requires_reload: bool = true, spammy: bool = false) -> void:
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
	save()

func _on_image_vis_set(new_value):
	SettingsHandler.image_default = new_value
	save(false)

func _on_signal_color_set(new_value):
	SettingsHandler.do_bbcode = new_value
	Main.on_dict_reload()
	save(false)

func _on_truncation_spinner_value_changed(value):
	SettingsHandler.truncate_message_size = roundi(value)
	save(true, true)

func _on_font_spinner_value_changed(value):
	SettingsHandler.font_size = value
	save(true, true)

func _try_address():
	Main.reconnect_or_change_url(address_edit.text)

func _on_adress_edit_text_submitted(_new_text):
	_try_address()

func _on_address_connect_pressed():
	_try_address()

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
	SettingsHandler.master_volume = _volume_slider_to_linear(value)
	SettingsHandler.evaluate_volume()
	if not sound_sample.playing:
		sound_sample.play()
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

func _on_directory_button_pressed():
	SaveSystem.change_directory_location()
