extends MeshInstance3D
class_name PlotNode

@export_color_no_alpha var Col: Color = Color(1.0, 1.0, 1.0)
@export var Radius: float = 1.0

func _enter_tree():
	var ball: SphereMesh = mesh
	ball.radius = Radius
	ball.height = Radius * 2.0
	var shader: ShaderMaterial = get_surface_override_material(0)
	shader.set_shader_parameter("col", Col)
