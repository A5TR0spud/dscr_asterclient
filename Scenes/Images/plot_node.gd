extends MeshInstance3D
class_name PlotNode

@export_color_no_alpha var col: Color = Color(1.0, 1.0, 1.0)
@export var radius: float = 1.0

func _enter_tree():
	var ball: SphereMesh = mesh
	ball.radius = radius
	ball.height = radius * 2.0
	var shader: ShaderMaterial = get_surface_override_material(0)
	shader.set_shader_parameter("col", col)
