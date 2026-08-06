extends ScrollContainer

var oldBottom: float = 0
@export var Tolerance: int = 25
@onready var scrollbar: VScrollBar = get_v_scroll_bar()

func _ready():
	scrollbar.connect("changed", Changed)
	oldBottom = 0

func Changed():
	var bottomScroll: float = oldBottom - scroll_vertical
	if bottomScroll <= Tolerance:
		scroll_vertical = ceili(scrollbar.max_value)
	oldBottom = scrollbar.max_value - scrollbar.page
