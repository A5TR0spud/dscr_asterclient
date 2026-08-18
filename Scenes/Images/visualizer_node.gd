extends Control
class_name VisualizeNode
# Helper method for calculating the sphere colors
# Visual Object colors are evaluated on a gradient [0, 64] to get RGB values. The full gradient linearly blends between keys. In the game, the keys are: 
# 0 - #FF5800 0-7
# 1 - #BBFF00 7-14
# 2 - #00CDFF 14-21
# 3 - #0084FF 21-28
# 4 - #4D00FF
# 5 - #FB39FF
# 6 - #FF0FD7
# 7 - #484848
# 8 - #636363
# 9 - #FFFFFF
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

var _sphere_data: Array[Dictionary] = []

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
const START: int = -14
const END  : int = -15

const NEG  : int = -1
const FRAC : int = -10

func check_image(message: Array) -> bool:
	var current_state: int = 0 # TODO: define as enum
	var build_data: Dictionary = {}
	var negative: bool = false
	var decimal: bool = false
	for i in message:
		if i is not int:
			current_state = 0
			build_data.clear()
			_sphere_data.clear()
			negative = false
			decimal = false
			continue
		i = i as int
		if i == IMAGE:
			if current_state != 0:
				build_data.clear()
				_sphere_data.clear()
				negative = false
				decimal = false
			current_state = 1
			#print("image detected")
			continue
		if i == START and current_state == 1:
			current_state = 2
			#print("start detected")
			continue
		if i == PLOT and current_state == 2:
			current_state = 3
			#print("plot detected")
			continue
		if (
			current_state >= 3 and current_state <= 7
		):
			if i == NEG:
				negative = true
				#print("negative")
				continue
			if i == FRAC:
				decimal = true
				#print("decimal")
				continue
			if i >= 0:
				#print("state = ", current_state)
				var num: float = i
				if decimal:
					num = ("0." + str(i)).to_float()
				if negative:
					num *= -1
				if current_state == 3:
					num += build_data.get("x", 0)
					build_data.set("x", num)
					#print("x = ", num)
				elif current_state == 4:
					num += build_data.get("y", 0)
					build_data.set("y", num)
					#print("y = ", num)
				elif current_state == 5:
					num += build_data.get("z", 0)
					build_data.set("z", num)
					#print("z = ", num)
				elif current_state == 6:
					num += build_data.get("r", 0)
					build_data.set("r", num)
					#print("r = ", num)
				elif current_state == 7:
					num += build_data.get("c", 0)
					build_data.set("c", num)
					#print("c = ", num)
				continue
			if i == SEP and current_state < 7:
				current_state += 1
				negative = false
				decimal = false
				#print("sep detected")
				continue
		if (i == END or SEP) and current_state == 7:
			#print("appending: ", build_data)
			_sphere_data.append(build_data)
			negative = false
			decimal = false
			build_data = {}
			current_state = 2
			#print("sep or end detected")
			if i == END:
				#print("end detected")
				break
			continue
		current_state = 0
		build_data.clear()
		_sphere_data.clear()
		negative = false
		decimal = false
	if _sphere_data.is_empty():
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
