extends Node3D
class_name ImageMaker

@onready var gizmo: Node3D = $Gizmo
@onready var axis_x: Area3D = $Gizmo/AxisX
@onready var axis_y: Area3D = $Gizmo/AxisY
@onready var axis_z: Area3D = $Gizmo/AxisZ
@onready var plane_yz: Area3D = $Gizmo/PlaneYZ
@onready var plane_xz: Area3D = $Gizmo/PlaneXZ
@onready var plane_xy: Area3D = $Gizmo/PlaneXY

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

func _process(delta):
	camera_pivot.rotation_degrees.y += 10 * delta
	camera.position.z = sin(Time.get_ticks_msec() * 0.001) + 4
	var yaw := camera.global_rotation.y
	var pitch := camera.global_rotation.x
	var x := sin(yaw)*cos(pitch)
	var y := sin(pitch)
	var z := cos(yaw)*cos(pitch)
	
	axis_x.visible = abs(x) < 0.985
	axis_y.visible = abs(y) < 0.985
	axis_z.visible = abs(z) < 0.985
	
	plane_yz.visible = abs(x) > 0.5
	plane_xz.visible = abs(y) > 0.5
	plane_xy.visible = abs(z) > 0.5
	
	var target_gizmo_pos: Vector3 = Vector3.ZERO
	var target_gizmo_dir: Vector3 = camera.global_position.direction_to(target_gizmo_pos)
	gizmo.global_position = camera.global_position + target_gizmo_dir * 6
	
