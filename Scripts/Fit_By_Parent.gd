extends Node
class_name FitByParent

@export var width_from_height: bool = true
@export var ratio: float = 1
@export var offset: int = 0

@onready var parent: Control = self.get_parent()

func _ready():
	if not parent: return
	parent.item_rect_changed.connect(refresh.call_deferred)

func refresh():
	if width_from_height:
		parent.custom_minimum_size.x = parent.size.y * ratio + offset
	else:
		parent.custom_minimum_size.y = parent.size.x * ratio + offset
