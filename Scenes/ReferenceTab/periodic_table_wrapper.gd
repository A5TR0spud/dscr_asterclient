extends VBoxContainer

@onready var setting: SettingEntry = $UseM0ElementNames
@onready var periodic_table: PeriodicTable = $MarginContainer/PeriodicTable
@onready var periodic_table_long: PeriodicTable = $MarginContainer/PeriodicTableLong

func _ready():
	Main.instance.reload_settings.connect(refresh)
	Main.instance.localization_reload.connect(refresh)

func refresh():
	setting.set_state_no_signal(SettingsHandler.use_m0_elements)
	setting.visible = SettingsHandler.use_m0_ui and DictionaryHandler.support_m0
	periodic_table.visible = !SettingsHandler.long_periodic_table
	periodic_table_long.visible = SettingsHandler.long_periodic_table

func _on_use_m_0_element_names_set(new_value):
	SettingsHandler.use_m0_elements = new_value
	SettingsHandler.save()
	Main.on_localization_reload()
