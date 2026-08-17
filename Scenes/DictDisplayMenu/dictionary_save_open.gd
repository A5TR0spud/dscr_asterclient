extends Button

func _ready():
	Main.instance.reload_dict.connect(refresh)
	refresh()

var cycle: float = 0
func _process(delta):
	offset_transform_enabled = DictionaryHandler.bad_dict
	if DictionaryHandler.bad_dict:
		var val: float = sin(cycle * 6 / Main.HE6_HALF_LIFE) * 0.5 + 0.5
		val = val + 0.75
		self_modulate = Color(val, val, val)
		offset_transform_scale.x = val * 0.1 + 0.95
		offset_transform_scale.y = val * 0.1 + 0.95
		var rot: float = sin(cycle * 5 / Main.HE6_HALF_LIFE) * 0.05
		offset_transform_rotation = rot
		cycle += delta
	else:
		self_modulate = Color(1.0, 1.0, 1.0)

func refresh():
	text = DictionaryHandler.get_or_default_signal_name(-40)
