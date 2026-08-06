extends CenterContainer

func _on_dict_edit_window_visibility_changed():
	visible = get_child(0).visible
