extends ScrollContainer
class_name AutoScrollContainer

var old_bottom: float = 0
@export var tolerance: int = 25
@onready var scrollbar: VScrollBar = get_v_scroll_bar()

func _ready():
	scrollbar.connect("changed", changed)
	old_bottom = 0

func changed():
	var bottom_scroll: float = old_bottom - scroll_vertical
	if bottom_scroll <= tolerance:
		scroll_vertical = ceili(scrollbar.max_value)
	old_bottom = scrollbar.max_value - scrollbar.page
