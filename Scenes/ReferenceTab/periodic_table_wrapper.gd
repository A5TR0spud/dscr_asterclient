extends VBoxContainer

@onready var setting: SettingEntry = $UseM0ElementNames

func _ready():
	Main.instance.reload_settings.connect(refresh)
	Main.instance.localization_reload.connect(refresh)

func refresh():
	setting.set_state_no_signal(SettingsHandler.use_m0_elements)
	setting.visible = SettingsHandler.use_m0_ui and DictionaryHandler.support_m0

func _on_use_m_0_element_names_set(new_value):
	SettingsHandler.use_m0_elements = new_value
	SettingsHandler.save()
	Main.on_localization_reload()
