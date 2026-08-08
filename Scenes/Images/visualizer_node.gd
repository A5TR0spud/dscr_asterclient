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
func calculateColor (value: int):
	var n: float = value / 64.0 * (COLORS.size() - 1);
	var lo = floor(n);
	var hi = ceil(n);
	var c = lerpColor(Color(COLORS[lo]), Color(COLORS[hi]), fmod(n, 1))
	return Color(c.r, c.g, c.b);

# i keep reading "larp" instead of "lerp"
func lerpColor(col1: Color, col2: Color, delta: float) -> Color:
	return col1 * (1.0 - delta) + col2 * delta

static var PlotScene := preload("res://Scenes/Images/plot_node.tscn")

@onready var camPivot: Node3D = $Intermediate/RenderAndYaw/VisualizerRect/SubViewport/CameraOrigin
@onready var cam: Camera3D = $Intermediate/RenderAndYaw/VisualizerRect/SubViewport/CameraOrigin/Cam
@onready var plots: Node3D = $Intermediate/RenderAndYaw/VisualizerRect/SubViewport/Plots
@onready var zoomS: Range = $Intermediate/ZoomSlider
@onready var yawS: Range = $Intermediate/RenderAndYaw/YawSlider
@onready var pitchS: Range = $Intermediate/PitchSlider

var _sphereData: Array[Dictionary] = []

func _on_zoom_slider_value_changed(value: float):
	value /= zoomS.min_value
	value = value + 1
	cam.position.z = 2.5 * value * value + 10.5 * value + 3

func _on_yaw_slider_value_changed(value: float):
	value /= zoomS.min_value
	camPivot.rotation_degrees.y = value * 360.0

func _on_pitch_slider_value_changed(value: float):
	value /= zoomS.min_value
	camPivot.rotation_degrees.x = -value * 70

const IMAGE: int = -53
const PLOT : int = -52
const SEP  : int = -3
const START: int = -14
const END  : int = -15

const NEG  : int = -1
const FRAC : int = -10

func CheckImage(messageToParse: Array) -> bool:
	var currentState: int = 0
	var builtData: Dictionary = {}
	var negative: bool = false
	var decimal: bool = false
	for i in messageToParse:
		if i is not int:
			currentState = 0
			builtData = {}
			_sphereData = []
			negative = false
			decimal = false
			continue
		i = i as int
		if i == IMAGE and currentState == 0:
			currentState = 1
			#print("image detected")
			continue
		if i == START and currentState == 1:
			currentState = 2
			#print("start detected")
			continue
		if i == PLOT and currentState == 2:
			currentState = 3
			#print("plot detected")
			continue
		if (
			currentState >= 3 and currentState <= 7
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
				#print("state = ", currentState)
				var num: float = i
				if decimal:
					num = ("0." + str(roundi(num))).to_float()
				if negative:
					num *= -1
				if currentState == 3:
					num += builtData.get("x", 0)
					builtData.set("x", num)
					#print("x = ", num)
				elif currentState == 4:
					num += builtData.get("y", 0)
					builtData.set("y", num)
					#print("y = ", num)
				elif currentState == 5:
					num += builtData.get("z", 0)
					builtData.set("z", num)
					#print("z = ", num)
				elif currentState == 6:
					num += builtData.get("r", 0)
					builtData.set("r", num)
					#print("r = ", num)
				elif currentState == 7:
					num += builtData.get("c", 0)
					builtData.set("c", num)
					#print("c = ", num)
				continue
			if i == SEP and currentState < 7:
				currentState += 1
				negative = false
				decimal = false
				#print("sep detected")
				continue
		if i == END or SEP and currentState == 7:
			_sphereData.append(builtData)
			negative = false
			decimal = false
			builtData = {}
			currentState = 2
			#print("sep or end detected")
			if i == END:
				#print("end detected")
				break
			continue
		currentState = 0
		builtData = {}
		_sphereData = []
		negative = false
		decimal = false
	if _sphereData.is_empty():
		return false
	for p in _sphereData:
		var plot: PlotNode = PlotScene.instantiate()
		plot.Col = calculateColor(p["c"])
		plot.Radius = p["r"] * 0.5
		plot.position.x = p["x"]
		plot.position.y = p["z"]
		plot.position.z = -p["y"]
		plots.add_child(plot)
	return true
