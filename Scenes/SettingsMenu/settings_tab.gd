extends VBoxContainer

func _ready() -> void:
	Main.instance.reload_settings.connect(refresh)

@onready var formatting: SettingEntry = $ScrollContainer/MarginContainer/Options/Formatting
@onready var image_visibility: SettingEntry = $ScrollContainer/MarginContainer/Options/ImageVis
@onready var truncate: SpinBox = $ScrollContainer/MarginContainer/Options/TruncMargin/TruncHbox/TruncationSpinner
@onready var font_size: SpinBox = $ScrollContainer/MarginContainer/Options/FontMargin/FontHbox/FontSpinner
@onready var address_edit: LineEdit = $ScrollContainer/MarginContainer/Options/Address/AdressEdit

func refresh() -> void:
	formatting.state = SettingsHandler.do_formatting
	image_visibility.state = SettingsHandler.image_default
	truncate.value = SettingsHandler.truncate_message_size
	font_size.value = SettingsHandler.font_size

func save() -> void:
	SettingsHandler.save()
	Main.on_settings_reload()

func _on_formatting_set(new_value):
	SettingsHandler.do_formatting = new_value
	save()

func _on_image_vis_set(new_value):
	SettingsHandler.image_default = new_value
	save()

var count: int = 0
func _physics_process(_delta):
	if count >= 5:
		if SettingsHandler.truncate_message_size != roundi(truncate.value):
			SettingsHandler.truncate_message_size = roundi(truncate.value)
			save()
		count = -1
	count += 1

func _on_font_spinner_value_changed(value):
	SettingsHandler.font_size = value
	save()

func _try_address():
	Main.reconnect_or_change_url(address_edit.text)

func _on_adress_edit_text_submitted(_new_text):
	_try_address()

func _on_address_connect_pressed():
	_try_address()
