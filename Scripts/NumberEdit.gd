extends SpinBox
class_name NumberEdit

func _ready():
	step = 0.0000001
	custom_arrow_step = 1
	max_value = INT64_MAX
	min_value = INT64_MIN
