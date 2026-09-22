@tool
extends MarginContainer
class_name IconButton

@export var icon: Texture2D:
	set(value):
		icon = value
		_on_change()
@export var expand_mode: TextureRect.ExpandMode = TextureRect.ExpandMode.EXPAND_FIT_WIDTH_PROPORTIONAL:
	set(value):
		expand_mode = value
		_on_change()
@export var tooltip_key: String = ""
@export var toggle_mode: bool = false:
	set(value):
		toggle_mode = value
		_on_change()
@export var button_pressed: bool = false:
	set(value):
		button_pressed = value
		_on_change()
@export var start_disabled: bool = false

@onready var tex_rect: TextureRect = $TextureRect
@onready var button: Button = $TextureRect/MarginContainer/Button

func set_disabled(is_disabled: bool):
	button.disabled = is_disabled
	tex_rect.self_modulate = Color(1.0, 1.0, 1.0, 0.33) if is_disabled else Color.WHITE
	button.mouse_default_cursor_shape = Control.CURSOR_ARROW if is_disabled else Control.CURSOR_POINTING_HAND

func is_pressed() -> bool:
	return button.button_pressed

func _ready():
	_on_change.call_deferred()
	set_disabled(start_disabled)
	if Engine.is_editor_hint():
		return
	button.pressed.connect(pressed.emit)
	button.toggled.connect(toggled.emit)
	if not tooltip_key.is_empty():
		Main.instance.localization_reload.connect(_refresh)
		Main.instance.reload_dict.connect(_refresh)

func _on_change():
	if not is_node_ready():
		return
	tex_rect.texture = icon
	tex_rect.expand_mode = expand_mode
	queue_sort()
	button.toggle_mode = toggle_mode
	button.button_pressed = button_pressed

func _refresh():
	tooltip_text = Localizer.translate(tooltip_key)

signal pressed
signal toggled(toggled_on: bool)
