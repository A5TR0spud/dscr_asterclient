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

func _input(event):
	if event is InputEventMouse and _is_hovering:
		event = event as InputEventMouse
		if event.button_mask != MouseButton.MOUSE_BUTTON_LEFT or not event.is_pressed():
			return
		if DictEditMenu.is_open():
			DictEditMenu.close()

var _is_hovering: bool = false
func _on_mouse_entered():
	_is_hovering = true

func _on_mouse_exited():
	_is_hovering = false
