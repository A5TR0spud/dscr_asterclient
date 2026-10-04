extends VBoxContainer

@onready var tabber: TabBar = $Header/Tabber
@onready var tab_parent: Control = $TabContainer


func _ready():
	tabber.current_tab = 0
	_show_tab(0)
	Main.instance.reload_dictionary_support.connect(_reload_support)

func _reload_support():
	while tabber.tab_count > 3:
		tabber.remove_tab(3)
	if DictionaryHandler.support_m0:
		tabber.add_tab("images")
	tabber.get_child(0).refresh()

func _on_tabber_tab_changed(tab: int):
	_show_tab(tab)

func _show_tab(tab: int):
	for idx in range(tab_parent.get_child_count()):
		tab_parent.get_child(idx).visible = idx == tab

func _on_library_force_select():
	tabber.current_tab = 1
	_show_tab(1)
