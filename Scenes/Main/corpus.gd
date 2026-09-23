extends VBoxContainer

@onready var tabber: TabBar = $Header/Tabber
@onready var tab_parent: Control = $TabContainer


func _ready():
	tabber.current_tab = 0
	_show_tab(0)

func _on_tabber_tab_changed(tab: int):
	_show_tab(tab)

func _show_tab(tab: int):
	for idx in range(tab_parent.get_child_count()):
		tab_parent.get_child(idx).visible = idx == tab

func _on_library_force_select():
	tabber.current_tab = 1
	_show_tab(1)
