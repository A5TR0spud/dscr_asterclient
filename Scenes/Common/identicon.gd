extends ColorRect
class_name Identicon

var num: int = 0:
	set(value):
		num = value
		color = Main.get_callsign_color(num)
		material.set_shader_parameter("Value", num) # TODO: camel case! 
		# shader uniforms automatically use english formatting in editor

func _ready():
	Main.instance.reload_settings.connect(refresh)

func refresh():
	custom_minimum_size.x = roundi(16.0 * SettingsHandler.font_size / 18.0)
	custom_minimum_size.y = custom_minimum_size.x
	custom_maximum_size = custom_minimum_size
