extends Control
class_name ImageMaker

@onready var gizmo: Node3D = $SubViewport/Gizmo
@onready var axis_x: Node3D = $SubViewport/Gizmo/AxisX
@onready var axis_y: Node3D = $SubViewport/Gizmo/AxisY
@onready var axis_z: Node3D = $SubViewport/Gizmo/AxisZ
@onready var plane_yz: Node3D = $SubViewport/Gizmo/PlaneYZ
@onready var plane_xz: Node3D = $SubViewport/Gizmo/PlaneXZ
@onready var plane_xy: Node3D = $SubViewport/Gizmo/PlaneXY
@onready var scalar_rod: Node3D = $SubViewport/Gizmo/Scalar/Handle

@onready var camera_pivot: Node3D = $SubViewport/CameraPivot
@onready var camera_node: Camera3D = $SubViewport/CameraPivot/Camera3D

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

@onready var object_type_chooser: TabBar = $HSplitContainer/MarginContainer/Sidebar/ObjectControls/HBoxContainer/ItemList
func _ready():
	reset_camera()
	_calc_slider_color()
	Main.instance.reload_dictionary_support.connect(func():
		object_type_chooser.visible = DictionaryHandler.support_dscr
		if not DictionaryHandler.support_dscr:
			object_type_chooser.current_tab = 0
	)

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

func _unhandled_input(event):
	if event.is_action_pressed("image_reset") and self.is_visible_in_tree():
		reset_camera()
		get_viewport().set_input_as_handled()
		return

func _on_view_gui_input(event):
	#if event is InputEventMouseButton:
	#	if event.button_index == MOUSE_BUTTON_LEFT and hovered_over_x_axis:
	#		return
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


@onready var slider_color: Range = $HSplitContainer/MarginContainer/Sidebar/ObjectControls/Properties/SliderC
@onready var spinner_color: Range = $HSplitContainer/MarginContainer/Sidebar/ObjectControls/Properties/SpinC
@onready var slider_radius: Range = $HSplitContainer/MarginContainer/Sidebar/ObjectControls/Properties/SliderR
@onready var spinner_radius: Range = $HSplitContainer/MarginContainer/Sidebar/ObjectControls/Properties/SpinR

func _on_slider_c_value_changed(value):
	spinner_color.set_value_no_signal(value)
	_calc_slider_color()
	if is_instance_valid(selected_obj):
		selected_obj.color = value
		selected_obj.refresh()
		_on_objects_list_child_order_changed()

func _on_spin_c_value_changed(value):
	slider_color.set_value_no_signal(value)
	_calc_slider_color()
	if is_instance_valid(selected_obj):
		selected_obj.color = value
		selected_obj.refresh()
		_on_objects_list_child_order_changed()

func _calc_slider_color():
	var col: Color = VisualizeNode.calculate_color(int(slider_color.value))
	col.r = col.r * 0.5 + 0.5
	col.g = col.g * 0.5 + 0.5
	col.b = col.b * 0.5 + 0.5
	slider_color.modulate = col

func _on_slider_r_value_changed(value):
	if value < 0.1:
		value = 0.1
	spinner_radius.set_value_no_signal(value)
	if is_instance_valid(selected_obj):
		selected_obj.radius = value
		selected_obj.refresh()
		_on_objects_list_child_order_changed()

func _on_spin_r_value_changed(value):
	slider_radius.set_value_no_signal(value)
	if is_instance_valid(selected_obj):
		selected_obj.radius = value
		selected_obj.refresh()
		_on_objects_list_child_order_changed()

@onready var viewport: SubViewport = $SubViewport
@onready var view: TextureRect = $HSplitContainer/View
func _on_view_resized():
	if viewport and view:
		viewport.size = view.size

@onready var obj_list: VBoxContainer = $HSplitContainer/MarginContainer/Sidebar/ScrollContainer/ObjectsList
@onready var xbox: Range = $HSplitContainer/MarginContainer/Sidebar/ObjectControls/Coordinates/SpinX
@onready var ybox: Range = $HSplitContainer/MarginContainer/Sidebar/ObjectControls/Coordinates/SpinY
@onready var zbox: Range = $HSplitContainer/MarginContainer/Sidebar/ObjectControls/Coordinates/SpinZ
@onready var sphere_mm: MultiMesh = $SubViewport/spheres.multimesh
@onready var cube_mm: MultiMesh = $SubViewport/cubes.multimesh
static var visual_obj = preload("res://Scenes/Images/ImageMakerTab/visual_object_entry.tscn")
var selected_obj: VisualObjectEntry = null
@onready var obj_label: Label = $HSplitContainer/MarginContainer/Sidebar/ObjectControls/HBoxContainer/ObjectLabel
func _select(v: VisualObjectEntry):
	if is_instance_valid(v):
		selected_obj = v
		slider_color.value = v.color
		slider_radius.value = v.radius
		xbox.value = v.x
		ybox.value = v.y
		zbox.value = v.z
		obj_label.text = Localizer.translate("COMPOSITOR_OBJ", v.get_index())
		return
	obj_label.text = ""

func _on_new_object_pressed():
	var new_obj: VisualObjectEntry = visual_obj.instantiate()
	new_obj.color = int(slider_color.value)
	new_obj.radius = spinner_radius.value
	if object_type_chooser.current_tab == 1:
		new_obj.type = VisualObjectEntry.ObjType.CUBE
	new_obj.hear_my_plea.connect(_select)
	obj_list.add_child(new_obj)
	_select(new_obj)

func _on_duplicate_pressed():
	if not is_instance_valid(selected_obj):
		return
	var new_obj: VisualObjectEntry = visual_obj.instantiate()
	new_obj.color = selected_obj.color
	new_obj.x = selected_obj.x
	new_obj.y = selected_obj.y
	new_obj.z = selected_obj.z
	new_obj.radius = selected_obj.radius
	new_obj.type = selected_obj.type
	new_obj.hear_my_plea.connect(_select)
	obj_list.add_child(new_obj)
	_select(new_obj)

func _on_delete_confirmed():
	if not is_instance_valid(selected_obj):
		return
	selected_obj.queue_free()
	if obj_list.get_child_count() > 0:
		_select(obj_list.get_child(0))

func _on_spin_x_value_changed(value):
	if is_instance_valid(selected_obj):
		selected_obj.x = value
		_on_objects_list_child_order_changed()

func _on_spin_y_value_changed(value):
	if is_instance_valid(selected_obj):
		selected_obj.y = value
		_on_objects_list_child_order_changed()

func _on_spin_z_value_changed(value):
	if is_instance_valid(selected_obj):
		selected_obj.z = value
		_on_objects_list_child_order_changed()

var signal_rep: PackedInt64Array = []

func _on_objects_list_child_order_changed():
	signal_rep = [-53, -14]
	sphere_mm.instance_count = 0
	cube_mm.instance_count = 0
	var ball: int = 0
	var cube: int = 0
	for c: VisualObjectEntry in obj_list.get_children():
		match c.type:
			VisualObjectEntry.ObjType.SPHERE:
				ball += 1
			VisualObjectEntry.ObjType.CUBE:
				cube += 1
	sphere_mm.instance_count = ball
	cube_mm.instance_count = cube
	ball = 0
	cube = 0
	var f: bool = true
	for c: VisualObjectEntry in obj_list.get_children():
		var mm: MultiMesh
		var idx: int
		if f:
			signal_rep.append(-3)
			f = false
		match c.type:
			VisualObjectEntry.ObjType.SPHERE:
				mm = sphere_mm
				idx = ball
				ball += 1
				signal_rep.append(-52)
			VisualObjectEntry.ObjType.CUBE:
				mm = cube_mm
				idx = cube
				cube += 1
				signal_rep.append(-52400)
		signal_rep.append_array(DictionaryHandler.number_to_signals(c.x))
		signal_rep.append_array(DictionaryHandler.number_to_signals(c.y))
		signal_rep.append_array(DictionaryHandler.number_to_signals(c.z))
		signal_rep.append(c.color)
		signal_rep.append_array(DictionaryHandler.number_to_signals(c.radius))
		mm.set_instance_color(idx, VisualizeNode.calculate_color(c.color).srgb_to_linear())
		mm.set_instance_transform(idx, Transform3D(
			# X Scale/Shear
			Vector3(c.radius, 0, 0),
			# Y Scale/Shear
			Vector3(0, c.radius, 0),
			# Z Scale/Shear
			Vector3(0, 0, c.radius),
			# Origin Position
			Vector3(c.x, c.z, -c.y)
		))
	signal_rep.append(-15)

func _on_delete_image_confirmed():
	for c: Node in obj_list:
		c.queue_free()


func _on_item_list_tab_selected(tab):
	if is_instance_valid(selected_obj):
		if tab == 1:
			selected_obj.type = VisualObjectEntry.ObjType.CUBE
		else:
			selected_obj.type = VisualObjectEntry.ObjType.SPHERE
		_on_objects_list_child_order_changed()
