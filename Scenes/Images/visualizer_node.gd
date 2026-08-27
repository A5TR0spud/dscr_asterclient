extends Control
class_name VisualizeNode
# Helper method for calculating the sphere colors
# Visual Object colors are evaluated on a gradient [0, 64] to get RGB values. The full gradient linearly blends between keys. In the game, the keys are: 
# 0 - #FF5800  0.00 red-orange
# 1 - #BBFF00  7.11 yellow-green
# 2 - #00CDFF 14.22 cyan
# 3 - #0084FF 21.33 light blue
# 4 - #4D00FF 28.44 blurple
# 5 - #FB39FF 35.56 bubblegum pink
# 6 - #FF0FD7 42.67 hot pink
# 7 - #484848 49.78 black
# 8 - #636363 56.89 grey
# 9 - #FFFFFF 64.00 white
# Code thanks to @elnico56 in discord!!!!
# Code adapted from https://github.com/dixonary/mfds-server/blob/0d359cef41a64cfe2bddbacb12898f066fa099b8/public/mfds.js#L1009-L1034
const COLORS: Array = [
	"FF5800", "BBFF00", "00CDFF", "0084FF", "4D00FF",
	"FB39FF", "FF0FD7", "484848", "636363", "FFFFFF"
];
static func calculate_color (value: int) -> Color:
	var n: float = value / 64.0 * (COLORS.size() - 1)
	var lo = floor(n)
	var hi = ceil(n)
	return lerp(Color(COLORS[lo]), Color(COLORS[hi]), fmod(n, 1))

static var plot_scene := preload("res://Scenes/Images/plot_node.tscn")

@onready var cam_pivot: Node3D = $Intermediate/RenderAndYaw/VisualizerRect/SubViewport/CameraOrigin
@onready var cam: Camera3D = $Intermediate/RenderAndYaw/VisualizerRect/SubViewport/CameraOrigin/Cam
@onready var plots: Node3D = $Intermediate/RenderAndYaw/VisualizerRect/SubViewport/Plots
@onready var zoom_slider: Range = $Intermediate/ZoomSlider
@onready var yaw_slider: Range = $Intermediate/RenderAndYaw/YawSlider
@onready var pitch_slider: Range = $Intermediate/PitchSlider
@onready var visualizer: TextureRect = $Intermediate/RenderAndYaw/VisualizerRect

var _sphere_data: Array = []

func _enter_tree():
	Main.instance.reload_image_inversion.connect(_refresh_inversions)

func _set_zoom(value: float) -> void:
	if SettingsHandler.img_invert_zoom:
		value *= -1
	value += 1
	cam.position.z = 2.5 * value * value + 10.5 * value + 3

func _set_yaw(value: float) -> void:
	if SettingsHandler.img_invert_yaw:
		value *= -1
	cam_pivot.rotation_degrees.y = value * 360.0

func _set_pitch(value: float) -> void:
	if SettingsHandler.img_invert_pitch:
		value *= -1
	cam_pivot.rotation_degrees.x = -value * 70

# untested but probably
# Returns the value of a scrollbar mapped to the interval [-1, 1]
#func _get_mapped_value(scroll: Range) -> float:
#	var _min: float = scroll.min_value
#	var _max: float = scroll.max_value - scroll.page
#	var mid: float = 0.5 * (_min + _max)
#	var v: float = (scroll.value - mid) / (_max - mid)
#	return v

func _refresh_inversions():
	_set_zoom(zoom_slider.value / zoom_slider.min_value)
	_set_pitch(pitch_slider.value / pitch_slider.min_value)
	_set_yaw(yaw_slider.value / yaw_slider.min_value)

func _on_zoom_slider_value_changed(value: float):
	# dividing by min value gets the ratio between -1 and 1
	# .ratio doesn't work in this case because it doesn't account for page size
	# this formula is a simplification that is correct for the current min, max, and page values
	value /= zoom_slider.min_value
	_set_zoom(value)

func _on_yaw_slider_value_changed(value: float):
	value /= zoom_slider.min_value
	_set_yaw(value)

func _on_pitch_slider_value_changed(value: float):
	value /= zoom_slider.min_value
	_set_pitch(value)

const IMAGE: int = -53
const PLOT : int = -52
const SEP  : int = -3

var first_sphere: bool = true

func _parse_sphere(parser: TransmissionParser) -> Dictionary:
	if (first_sphere and parser.peek() == PLOT) or not first_sphere:
		parser.expect(PLOT)
	var x = parser.read_number()
	parser.expect(SEP)
	var y = parser.read_number()
	parser.expect(SEP)
	var z = parser.read_number()
	parser.expect(SEP)
	var r = parser.read_number()
	parser.expect(SEP)
	var c = parser.read_number()
	parser.try_consume(SEP)
	first_sphere = false

	return {"x": x, "y": y, "z": z, "r": r, "c": c}

func check_image(message0: Array) -> bool:
	for c in plots.get_children():
		c.queue_free()
	_sphere_data.clear()
	var message: Array[int] = []
	for u in message0:
		if u is int:
			message.append(u)
		else:
			return false
	var parser = TransmissionParser.new(message)
	while not parser.is_at_end():
		if not parser.skip_to(IMAGE): return false
		parser.expect(IMAGE)
		first_sphere = true
		var pos := parser.save_state()
		var spheres = parser.read_group_items(_parse_sphere)

		if parser.has_error():
			print(parser.get_error_message())
			parser.restore_state(pos, true)
			continue

		_sphere_data = spheres
		break

	if _sphere_data.is_empty():
		#print("empty image")
		return false
	for p: Dictionary in _sphere_data:
		#print("dat: ", p)
		var plot: PlotNode = plot_scene.instantiate()
		plot.col = calculate_color(p["c"])
		plot.radius = p["r"] * 0.5
		plot.position.x = p["x"]
		plot.position.y = p["z"]
		plot.position.z = -p["y"]
		plots.add_child(plot)
	return true

var mouse_teleported: bool = false
func _on_visualizer_rect_gui_input(event: InputEvent):
	if event.is_action_pressed("zoom in"):
		zoom_slider.value += event.get_action_strength("zoom in") * zoom_slider.page * 0.5
		accept_event()
		return
	if event.is_action_pressed("zoom out"):
		zoom_slider.value -= event.get_action_strength("zoom out") * zoom_slider.page * 0.5
		accept_event()
		return
	if not Input.is_action_pressed("rotate_image"):
		return
	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		var motion: Vector2 = event.relative
		motion.x /= yaw_slider.size.x
		motion.y /= pitch_slider.size.y
		motion.x *= yaw_slider.max_value - yaw_slider.min_value - yaw_slider.page
		motion.y *= pitch_slider.max_value - pitch_slider.min_value - pitch_slider.page
		if mouse_teleported:
			mouse_teleported = false
			return
		var mouse_pos: Vector2 = visualizer.get_local_mouse_position()
		if mouse_pos.x < 0:
			mouse_pos.x = visualizer.size.x - 1
			visualizer.warp_mouse(mouse_pos)
			mouse_teleported = true
		if mouse_pos.x > visualizer.size.x:
			mouse_pos.x = 1
			visualizer.warp_mouse(mouse_pos)
			mouse_teleported = true
		if mouse_pos.y < 0:
			mouse_pos.y = visualizer.size.y - 1
			visualizer.warp_mouse(mouse_pos)
			mouse_teleported = true
		if mouse_pos.y > visualizer.size.y:
			mouse_pos.y = 1
			visualizer.warp_mouse(mouse_pos)
			mouse_teleported = true
		var yaw: float = yaw_slider.value + motion.x
		if yaw > yaw_slider.max_value - yaw_slider.page:
			yaw -= yaw_slider.max_value - yaw_slider.min_value - yaw_slider.page
			mouse_teleported = true
		if yaw < yaw_slider.min_value:
			yaw += yaw_slider.max_value - yaw_slider.min_value - yaw_slider.page
			mouse_teleported = true
		yaw_slider.value = yaw
		pitch_slider.value += motion.y
		accept_event()
		return
