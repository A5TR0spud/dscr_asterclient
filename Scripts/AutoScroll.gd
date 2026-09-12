extends ScrollContainer
class_name AutoScrollContainer

var _old_bottom: float = 0
@export var tolerance: int = 25
@onready var _scrollbar: VScrollBar = get_v_scroll_bar()

func _was_scrolled_to_bottom() -> bool:
	var bottom_scroll: float = _old_bottom - scroll_vertical
	return bottom_scroll <= tolerance

func get_scroll_from_bottom() -> float:
	return _scrollbar.max_value - _scrollbar.page - _scrollbar.value

func is_scrolled_to_bottom() -> bool:
	return get_scroll_from_bottom() <= tolerance

func bottom_is_visible() -> bool:
	if is_scrolled_to_bottom():
		return true
	if _scrollbar.page + tolerance >= _scrollbar.max_value - _scrollbar.min_value:
		return true
	return _was_scrolled_to_bottom()

func _ready():
	_scrollbar.changed.connect(_on_changed)
	_old_bottom = 0

func scroll_to_bottom(do_signal: bool = true):
	if do_signal:
		_scrollbar.value = ceili(_scrollbar.max_value)
	else:
		_scrollbar.set_value_no_signal(ceili(_scrollbar.max_value))

func _on_changed():
	if _was_scrolled_to_bottom() and not is_scrolled_to_bottom():
		scroll_to_bottom()
	_old_bottom = _scrollbar.max_value - _scrollbar.page
