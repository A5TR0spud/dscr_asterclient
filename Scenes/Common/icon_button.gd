@tool
extends PanelContainer
class_name IconButton

@export var icon: Texture2D:
	set(value):
		if not is_node_ready():
			await ready
		icon = value
		tex_rect.texture = value
@export var expand_mode: TextureRect.ExpandMode = TextureRect.ExpandMode.EXPAND_FIT_HEIGHT_PROPORTIONAL:
	set(value):
		if not is_node_ready():
			await ready
		expand_mode = value
		tex_rect.expand_mode = value
@export var tooltip_key: String = ""
@export var force_size: bool = false:
	set(value):
		if not is_node_ready():
			await ready
		force_size = value
		tex_rect.custom_minimum_size = Vector2(22, 22) if value else -Vector2.ONE
@export var toggle_mode: bool:
	get:
		if not button:
			await ready
		return button.toggle_mode
	set(value):
		if not button:
			await ready
		button.toggle_mode = value
@export var button_pressed: bool:
	get:
		if not button:
			await ready
		return button.button_pressed
	set(value):
		if not button:
			await ready
		button.button_pressed = value


@onready var tex_rect: TextureRect = $MarginContainer/TextureRect
@onready var button: Button = $Button

func _ready():
	tex_rect.texture = icon
	tex_rect.expand_mode = expand_mode
	tex_rect.custom_minimum_size = Vector2(22, 22) if force_size else Vector2.ZERO
	if Engine.is_editor_hint():
		return
	button.pressed.connect(pressed.emit)
	button.toggled.connect(toggled.emit)
	if not tooltip_key.is_empty():
		Main.instance.localization_reload.connect(_refresh)

func _refresh():
	tooltip_text = Localizer.translate(tooltip_key)

signal pressed
signal toggled(toggled_on: bool)
