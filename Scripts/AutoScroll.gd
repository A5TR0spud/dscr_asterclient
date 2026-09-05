extends ScrollContainer
class_name AutoScrollContainer

var old_bottom: float = 0
@export var tolerance: int = 25
@onready var scrollbar: VScrollBar = get_v_scroll_bar()

func _was_scrolled_to_bottom() -> bool:
	var bottom_scroll: float = old_bottom - scroll_vertical
	return bottom_scroll <= tolerance

func get_scroll_from_bottom() -> float:
	return scrollbar.max_value - scrollbar.page - scrollbar.value

func is_scrolled_to_bottom() -> bool:
	return get_scroll_from_bottom() <= tolerance

func bottom_is_visible() -> bool:
	if is_scrolled_to_bottom():
		return true
	if scrollbar.page + tolerance >= scrollbar.max_value - scrollbar.min_value:
		return true
	return _was_scrolled_to_bottom()

func _ready():
	scrollbar.changed.connect(_on_changed)
	old_bottom = 0

func scroll_to_bottom(do_signal: bool = true):
	if do_signal:
		scrollbar.value = ceili(scrollbar.max_value)
	else:
		scrollbar.set_value_no_signal(ceili(scrollbar.max_value))

func _on_changed():
	if _was_scrolled_to_bottom() and not is_scrolled_to_bottom():
		scroll_to_bottom()
	old_bottom = scrollbar.max_value - scrollbar.page
