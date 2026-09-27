shader_type spatial;
render_mode cull_back, unshaded;

uniform vec3 albedo : source_color = vec3(1.0, 1.0, 1.0);

void vertex() {
	Z_CLIP_SCALE = 0.01;
}

void fragment() {
	ALBEDO = albedo;
}
