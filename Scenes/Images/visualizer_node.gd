extends Control
class_name VisualizeNode

@onready var cam_pivot: Node3D = $Intermediate/Corpus/RenderAndYaw/VisualizerRect/SubViewport/CameraOrigin
@onready var cam: Camera3D = $Intermediate/Corpus/RenderAndYaw/VisualizerRect/SubViewport/CameraOrigin/Cam
@onready var zoom_slider: Range = $Intermediate/Corpus/ZoomSlider
@onready var yaw_slider: Range = $Intermediate/Corpus/RenderAndYaw/YawSlider
@onready var pitch_slider: Range = $Intermediate/Corpus/PitchSlider
@onready var visualizer: TextureRect = $Intermediate/Corpus/RenderAndYaw/VisualizerRect
@onready var viewport: SubViewport = $Intermediate/Corpus/RenderAndYaw/VisualizerRect/SubViewport
@onready var res_button: IconButton = $Intermediate/Corpus/VBoxContainer/ResolutionButton
@onready var center_button: IconButton = $Intermediate/Corpus/VBoxContainer/CenterButton
@onready var header: Control = $Intermediate/Header
@onready var index_display: Label = $Intermediate/Header/Label

func _ready():
	Main.instance.reload_image_inversion.connect(_refresh_inversions)
	if res_button.visible:
		Main.instance.reload_settings.connect(_viewport_res)
		_viewport_res()

func _set_zoom(value: float) -> void:
	if SettingsHandler.img_invert_zoom:
		value *= -1
	value += 1
	cam.position.z = 2.5 * value * value + 10.5 * value + 3
	_calc_center_button_enabled()

func _set_yaw(value: float) -> void:
	if SettingsHandler.img_invert_yaw:
		value *= -1
	cam_pivot.rotation_degrees.y = value * 360.0
	_calc_center_button_enabled()

func _set_pitch(value: float) -> void:
	if SettingsHandler.img_invert_pitch:
		value *= -1
	cam_pivot.rotation_degrees.x = -value * 70
	_calc_center_button_enabled()

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

@onready var plot_spheres: MultiMeshInstance3D = $Intermediate/Corpus/RenderAndYaw/VisualizerRect/SubViewport/Spheres
@onready var multimesh_spheres: MultiMesh = plot_spheres.multimesh
@onready var plot_cubes: MultiMeshInstance3D = $Intermediate/Corpus/RenderAndYaw/VisualizerRect/SubViewport/Cubes
@onready var multimesh_cubes: MultiMesh = plot_cubes.multimesh
@onready var line_mesh: ImmediateMesh = $Intermediate/Corpus/RenderAndYaw/VisualizerRect/SubViewport/Lines.mesh

var saved_data: Array[SignalRendering.VisualData] = []
var data_index: int = 0

func prepare_from_multiple(data: Array[SignalRendering.VisualData]):
	saved_data = data
	if not data.is_empty():
		data_index %= data.size()
		render_data(data[data_index])
		index_display.text = Localizer.translate("IMAGE_CURRENT", [data_index + 1, data.size()])
		header.visible = data.size() > 1
		return
	header.hide()
	data_index = 0
	render_data(SignalRendering.VisualData.new())

func _on_next_button_pressed():
	if saved_data.is_empty():
		return
	data_index = (data_index + 1) % saved_data.size()
	index_display.text = Localizer.translate("IMAGE_CURRENT", [data_index + 1, saved_data.size()])
	render_data(saved_data[data_index])

func _on_prev_button_pressed():
	if saved_data.is_empty():
		return
	data_index = posmod(data_index - 1, saved_data.size())
	index_display.text = Localizer.translate("IMAGE_CURRENT", [data_index + 1, saved_data.size()])
	render_data(saved_data[data_index])

func render_data(data: SignalRendering.VisualData):
	multimesh_spheres.instance_count = 0
	line_mesh.clear_surfaces()

	data.objects = data.objects.filter(
		func(a: SignalRendering.VisualObject):
			return (a.delta[a.delta.max_axis_index()] > 0) or a.type == SigDB.RENDER_LINE
	)
	var _ball_count: int = 0
	var _cube_count: int = 0
	for v: SignalRendering.VisualObject in data.objects:
		if v.type == SigDB.RENDER_SPHERE:
			_ball_count += 1
		elif v.type == SigDB.CUBE or v.type == SigDB.BOX:
			_cube_count += 1
	multimesh_spheres.instance_count = _ball_count
	multimesh_cubes.instance_count = _cube_count
	var _balldx: int = 0
	var _cubedx: int = 0
	for p: SignalRendering.VisualObject in data.objects:
		var t: int = p.type
		var c: Color = SignalRendering.calculate_color(p.color).srgb_to_linear()
		if t != SigDB.RENDER_LINE:
			var mm: MultiMesh
			var idx: int = 0
			if t == SigDB.RENDER_SPHERE:
				mm = multimesh_spheres
				idx = _balldx
				_balldx += 1
			else:
				mm = multimesh_cubes
				idx = _cubedx
				_cubedx += 1
			mm.set_instance_color(idx, c)
			mm.set_instance_transform(idx, Transform3D(
				# X Scale/Shear
				Vector3(p.delta.x, 0, 0),
				# Y Scale/Shear
				Vector3(0, p.delta.z, 0),
				# Z Scale/Shear
				Vector3(0, 0, p.delta.y),
				# Origin Position
				Vector3(p.pos.x, p.pos.z, -p.pos.y)
			))
		else:
			line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
			line_mesh.surface_set_color(c)
			line_mesh.surface_add_vertex(Vector3(p.x, p.z, -p.y))
			line_mesh.surface_set_color(c)
			line_mesh.surface_add_vertex(Vector3(p.rx, p.rz, -p.ry))
			line_mesh.surface_end()
	_viewport_res.call_deferred()
	return true


var _held_mouse_pos: Vector2
var _is_holding: bool = false
func _on_visualizer_rect_gui_input(event: InputEvent):
	if event.is_action_pressed("zoom in"):
		zoom_slider.value += event.get_action_strength("zoom in") * zoom_slider.page * 0.5
		accept_event()
		return
	if event.is_action_pressed("zoom out"):
		zoom_slider.value -= event.get_action_strength("zoom out") * zoom_slider.page * 0.5
		accept_event()
		return
	if event.is_action_released("rotate_image"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		visualizer.warp_mouse.call_deferred(_held_mouse_pos)
		_is_holding = false
		accept_event()
		return
	if event.is_action_pressed("rotate_image"):
		_held_mouse_pos = visualizer.get_local_mouse_position()
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		_is_holding = true
		accept_event()
		return
	if event is InputEventMouseMotion and Input.is_action_pressed("pan_image") and not Input.is_action_pressed("rotate_image"):
		var dx: float = -event.relative.x * 0.005 * cam.position.z / size.x * 480
		var dy: float = event.relative.y * 0.005 * cam.position.z / size.x * 480
		var _yaw: float = cam_pivot.rotation.y
		var _pitch: float = cam_pivot.rotation.x
		
		var _newpos: Vector3 = cam_pivot.position
		# horizontal panning
		_newpos.x += dx * cos(_yaw)
		_newpos.z += -dx * sin(_yaw)
		# vertical panning
		_newpos.y += dy * cos(_pitch)
		_newpos.x += dy * sin(_yaw) * sin(_pitch)
		_newpos.z += dy * cos(_yaw) * sin(_pitch)
		
		cam_pivot.position = _newpos.clamp(Vector3(-16, -12, -16), Vector3(16, 12, 16))
		
		accept_event()
		_calc_center_button_enabled()
		return
	if !_is_holding:
		return
	if visualizer.get_local_mouse_position() == _held_mouse_pos:
		return
	visualizer.warp_mouse.call_deferred(_held_mouse_pos)
	if event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		var motion: Vector2 = event.position - _held_mouse_pos
		motion.x *= yaw_slider.max_value - yaw_slider.min_value - yaw_slider.page
		motion.y *= pitch_slider.max_value - pitch_slider.min_value - pitch_slider.page
		motion.x /= yaw_slider.size.x
		motion.y /= pitch_slider.size.y
		var yaw: float = yaw_slider.value + motion.x
		if yaw > yaw_slider.max_value - yaw_slider.page:
			yaw -= yaw_slider.max_value - yaw_slider.min_value - yaw_slider.page
		if yaw < yaw_slider.min_value:
			yaw += yaw_slider.max_value - yaw_slider.min_value - yaw_slider.page
		yaw_slider.value = yaw
		pitch_slider.value += motion.y
		accept_event()
		return

func _on_resize_button_gui_input(event: InputEvent):
	if !Input.is_action_pressed("rotate_image"):
		return
	if event is InputEventMouseMotion:
		custom_maximum_size.x = max(custom_minimum_size.x, custom_maximum_size.x + event.relative.x)
		if res_button.is_pressed():
			_viewport_res.bind(true).call_deferred()

func _on_resolution_button_toggled(toggled_on):
	_viewport_res(toggled_on)

func _viewport_res(high_res: bool = res_button.is_pressed()):
	if high_res:
		viewport.size = Vector2(visualizer.size.x, visualizer.size.x * 128.0/200.0)
	else:
		viewport.size = Vector2i(100, 64) if (
			SettingsHandler.crunch_image
		) else Vector2i(200, 128)

func _on_center_button_pressed():
	yaw_slider.value = 0
	zoom_slider.value = 0
	pitch_slider.value = 0
	cam_pivot.position = Vector3.ZERO
	center_button.set_disabled(true)

func _calc_center_button_enabled():
	center_button.set_disabled(
		yaw_slider.value == 0 and
		zoom_slider.value == 0 and
		pitch_slider.value == 0 and
		cam_pivot.position == Vector3.ZERO
	)
