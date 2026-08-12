extends Control
class_name Identicon

var _col: Color = Color.WHITE:
	get:
		return Main.GetCallsignColor(num)

@export var num: int = 0:
	set(value):
		num = value
		queue_redraw()

@export var icon_size: int = 16:
	set(value):
		icon_size = value
		custom_minimum_size.x = icon_size
		custom_minimum_size.y = custom_minimum_size.x
		custom_maximum_size = custom_minimum_size
		queue_redraw()

func _ready():
	Main.instance.reload_settings.connect(refresh)

func refresh():
	icon_size = roundi(16.0 * SettingsHandler.FontSize / 18.0)

func _draw():
	var subsize: float = icon_size * 0.2
	for i: int in range(15):
		var x: int = i % 3
		var y: int = floori(i / 3.0)
		var r: int = num
		if r % 2 == 0:
			y = 4 - y
		if (r % 3) == 0:
			x = 2 - x
		y = (r % 5 + y) % 5
		
		var idx: int = x + y * 3
		if y == 2:
			idx += 6
		if y > 2:
			idx -= 3
		var big_skip: bool = false
		for j: int in range(12):
			if r % 2 == 0 and idx == j:
				big_skip = true
				break
			r = floori(r * 0.5)
		if big_skip:
			continue
		if (idx == 12) and (Num % 7) == 1:
			continue
		if (idx == 13) and (Num % 11) == 1:
			continue
		if (idx == 14) and (Num % 13) == 1:
			continue
		draw_rect(Rect2(
			Vector2((2 - i % 3) * subsize, floori(i / 3.0) * subsize),
			Vector2(subsize, subsize)),
		_col)
		if i % 3 != 0:
			draw_rect(Rect2(
				Vector2((2 + i % 3) * subsize, floori(i / 3.0) * subsize),
				Vector2(subsize, subsize)),
			_col)
