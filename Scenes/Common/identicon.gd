extends ColorRect
class_name Identicon

var Num: int = 0:
	set(value):
		Num = value
		color = Main.GetCallsignColor(Num)
		material.set_shader_parameter("Value", Num)
