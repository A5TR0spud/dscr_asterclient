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
func calculate_color (value: int) -> Color:
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

var _sphere_data: Array[Dictionary] = []

func _on_zoom_slider_value_changed(value: float):
	value /= zoom_slider.min_value
	value = value + 1
	cam.position.z = 2.5 * value * value + 10.5 * value + 3

func _on_yaw_slider_value_changed(value: float):
	value /= zoom_slider.min_value # TODO: figure out if this should divide by yaw slider min value
	cam_pivot.rotation_degrees.y = value * 360.0

func _on_pitch_slider_value_changed(value: float):
	value /= zoom_slider.min_value # TODO: same as above
	cam_pivot.rotation_degrees.x = -value * 70

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
