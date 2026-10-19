extends PanelContainer

@onready var rainbow: TextureRect = $VBoxContainer/Rainbow
@onready var notch_label: Control = $VBoxContainer/Labels
@onready var cursor_label: Control = $VBoxContainer/CursorLabel
@onready var cursor_num: Label = $VBoxContainer/CursorLabel/Label

func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var x: float = rainbow.get_local_mouse_position().x / rainbow.size.x
		var i: int = clampi(int(65.0 * x), 0, 64)
		cursor_num.offset_transform_position_ratio.x = i / 64.0 - 0.5
		cursor_num.text = str(i)

func _on_mouse_entered():
	notch_label.hide()
	cursor_label.show()

func _on_mouse_exited():
	notch_label.show()
	cursor_label.hide()
