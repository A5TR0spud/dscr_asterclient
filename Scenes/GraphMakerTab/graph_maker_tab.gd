extends VBoxContainer

@export var visual: VisualizeNode

@onready var xmin: SpinBox = $HBoxContainer/XSize/XMin
@onready var xmax: SpinBox = $HBoxContainer/XSize/XMax
@onready var xqnt: SpinBox = $HBoxContainer/XSize/XCount
@onready var ymin: SpinBox = $HBoxContainer/YSize/YMin
@onready var ymax: SpinBox = $HBoxContainer/YSize/YMax
@onready var yqnt: SpinBox = $HBoxContainer/YSize/YCount
@onready var zmin: SpinBox = $HBoxContainer/ZSize/ZMin
@onready var zmax: SpinBox = $HBoxContainer/ZSize/ZMax
@onready var zqnt: SpinBox = $HBoxContainer/ZSize/ZCount

func diameter_at_pos(_pos: Vector3) -> float:
	return 1

func color_at_pos(pos: Vector3) -> int:
	@warning_ignore("narrowing_conversion")
	return (pos.z / 2.0) + (pos.y * 2.0) + (pos.x * 8.0)

func _ready():
	regenerate()

func regenerate():
	var dat: SignalRendering.VisualData = SignalRendering.VisualData.new()
	for xdx: int in range(xqnt.value):
		for ydx: int in range(yqnt.value):
			for zdx: int in range(zqnt.value):
				var p: SignalRendering.VisualObject = SignalRendering.VisualObject.new()
				var x: float = (xdx * (xmax.value - xmin.value)) / maxf(1, xqnt.value - 1) + xmin.value
				var y: float = (ydx * (ymax.value - ymin.value)) / maxf(1, yqnt.value - 1) + ymin.value
				var z: float = (zdx * (zmax.value - zmin.value)) / maxf(1, zqnt.value - 1) + zmin.value
				p.pos = Vector3(x, y, z)
				p.color = color_at_pos(p.pos)
				p.type = SigDB.RENDER_SPHERE
				var d: float = diameter_at_pos(p.pos)
				p.delta = Vector3(d, d, d)
				dat.objects.append(p)
	visual.prepare_from_multiple([dat])

func _on_x_min_value_changed(_value):
	regenerate()
func _on_x_max_value_changed(_value):
	regenerate()
func _on_x_count_value_changed(_value):
	regenerate()
func _on_y_min_value_changed(_value):
	regenerate()
func _on_y_max_value_changed(_value):
	regenerate()
func _on_y_count_value_changed(_value):
	regenerate()
func _on_z_min_value_changed(_value):
	regenerate()
func _on_z_max_value_changed(_value):
	regenerate()
func _on_z_count_value_changed(_value):
	regenerate()
