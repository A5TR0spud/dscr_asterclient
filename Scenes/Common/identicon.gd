extends ColorRect
class_name Identicon

var Num: int = 0:
	set(value):
		Num = value
		color = Main.GetCallsignColor(Num)
		material.set_shader_parameter("Value", Num)

func _ready():
	Main.instance.ReloadSettings.connect(Refresh)

func Refresh():
	custom_minimum_size.x = roundi(16.0 * SettingsHandler.FontSize / 18.0)
	custom_minimum_size.y = custom_minimum_size.x
	custom_maximum_size = custom_minimum_size
