extends VBoxContainer

@onready var setting_m0_names: SettingEntry = $UseM0ElementNames
@onready var periodic_table_tabbar: TabBar = $PDTabber
@onready var periodic_table_container: Container = $MarginContainer

func _ready():
	Main.instance.reload_settings.connect(refresh)
	Main.instance.localization_reload.connect(refresh)
	refresh()

func refresh():
	setting_m0_names.set_state_no_signal(SettingsHandler.use_m0_elements)
	setting_m0_names.visible = SettingsHandler.use_m0_ui and DictionaryHandler.support_m0
	periodic_table_tabbar.current_tab = SettingsHandler.periodic_table_visualization
	for i in periodic_table_tabbar.tab_count:
		periodic_table_container.get_child(i).visible = periodic_table_tabbar.current_tab == i

func _on_use_m_0_element_names_set(new_value):
	SettingsHandler.use_m0_elements = new_value
	SettingsHandler.save()
	Main.on_localization_reload()

func _on_pd_tabber_tab_changed(tab):
	SettingsHandler.periodic_table_visualization = tab
	SettingsHandler.save()
	refresh()
