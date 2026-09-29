extends Node3D
class_name ImageMaker

@onready var gizmo: Node3D = $Gizmo
@onready var axis_x: Node3D = $Gizmo/AxisX
@onready var axis_y: Node3D = $Gizmo/AxisY
@onready var axis_z: Node3D = $Gizmo/AxisZ
@onready var plane_yz: Node3D = $Gizmo/PlaneYZ
@onready var plane_xz: Node3D = $Gizmo/PlaneXZ
@onready var plane_xy: Node3D = $Gizmo/PlaneXY
@onready var scalar_rod: Node3D = $Gizmo/Scalar/Handle

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_node: Camera3D = $CameraPivot/Camera3D

var _yaw: float = 0:
	set(value):
		if value > PI:
			value -= TAU
		if value < -PI:
			value += TAU
		_yaw = value
var _pitch: float = 0:
	set(value):
		_pitch = clamp(value, -PI*0.5, PI*0.5)
var _zoom_level: int = BASE_ZOOM_LEVEL:
	set(value):
		value = clamp(value, 1, 8)
		if value != _zoom_level:
			_queued_zoom = true
		_zoom_level = value

const BASE_ZOOM_LEVEL: int = 6
#const BASE_ZOOM_AMOUNT: float = 4 * (1.5 ** (BASE_ZOOM_LEVEL - 4))

func reset_camera() -> void:
	_yaw = 0
	_pitch = 0
	_zoom_level = BASE_ZOOM_LEVEL
	camera_pivot.global_position = Vector3.ZERO

func _ready():
	reset_camera()

var target_gizmo_pos: Vector3 = Vector3.ZERO
var _queued_zoom: bool = true
func _process(delta):
	camera_pivot.rotation.y = _yaw
	camera_pivot.rotation.x = _pitch
	if _queued_zoom:
		camera_node.position.z = 8 * (1.5 ** (_zoom_level - 4))
		_queued_zoom = false
	#var x := sin(_yaw)*cos(_pitch)
	#var y := sin(_pitch)
	#var z := cos(_yaw)*cos(_pitch)
	
	#axis_x.visible = abs(x) < 0.985
	#axis_y.visible = abs(y) < 0.985
	#axis_z.visible = abs(z) < 0.985
	#
	#plane_yz.visible = abs(x) > 0.5
	#plane_xz.visible = abs(y) > 0.5
	#plane_xy.visible = abs(z) > 0.5
	
	#gizmo.scale.x = gizmo.position.distance_to(camera_node.global_position) / BASE_ZOOM_AMOUNT
	#gizmo.scale.y = gizmo.scale.x
	#gizmo.scale.z = gizmo.scale.x
	#var target_gizmo_dir: Vector3 = camera_node.global_position.direction_to(target_gizmo_pos)
	#gizmo.global_position = camera_node.global_position + target_gizmo_dir * 6
	#scalar_rod.scale.x = 3 / camera_node.global_position.distance_to(target_gizmo_pos)
	#scalar_rod.scale.y = scalar_rod.scale.x
	#scalar_rod.scale.z = scalar_rod.scale.x
	
	var motion_in: Vector3 = Vector3(
		Input.get_axis("image_leftward", "image_rightward"),
		Input.get_axis("image_downward", "image_upward"),
		Input.get_axis("image_forward", "image_backward")
	)
	if motion_in != Vector3.ZERO:
		motion_in = motion_in.rotated(Vector3.UP, _yaw).rotated(Vector3.LEFT.rotated(Vector3.UP, _yaw), -_pitch).normalized()
		if Input.is_action_pressed("image_sprint"):
			motion_in *= 2.5
		camera_pivot.position += motion_in * 3 * delta

func _unhandled_input(event: InputEvent):
	#if event is InputEventMouseButton:
	#	if event.button_index == MOUSE_BUTTON_LEFT and hovered_over_x_axis:
	#		return
	if event.is_action_pressed("image_reset"):
		reset_camera()
		get_viewport().set_input_as_handled()
		return
	if event.is_action("rotate_image") or event.is_action("pan_image"):
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("zoom in"):
		_zoom_level += 1
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("zoom out"):
		_zoom_level -= 1
		get_viewport().set_input_as_handled()
		return
	# panning
	if event is InputEventMouseMotion and Input.is_action_pressed("pan_image"):
		var dx: float = -event.relative.x * 0.001 * camera_node.position.z
		var dy: float = event.relative.y * 0.001 * camera_node.position.z
		#camera_node.position.x -= event.relative.x * 0.01
		#camera_node.position.y += event.relative.y * 0.01
		#x sin(yaw)+cos(pitch)
		#y sin(pitch)
		#z cos(yaw)*cos(pitch)
		# horizontal panning
		camera_pivot.position.x += dx * cos(_yaw)
		camera_pivot.position.z += -dx * sin(_yaw)
		# vertical panning
		camera_pivot.position.y += dy * cos(_pitch)
		camera_pivot.position.x += dy * sin(_yaw) * sin(_pitch)
		camera_pivot.position.z += dy * cos(_yaw) * sin(_pitch)
		return
	# rotating
	if event is InputEventMouseMotion and Input.is_action_pressed("rotate_image"):
		_yaw -= event.relative.x * 0.005
		_pitch -= event.relative.y * 0.005
		return
