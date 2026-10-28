extends SpinBox
class_name NumberEditSpinBox

func _ready():
	step = 1e-14
	custom_arrow_step = 1
	max_value = INT64_MAX
	min_value = INT64_MIN
