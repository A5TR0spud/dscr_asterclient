shader_type spatial;
render_mode unshaded, cull_front;

void vertex() {
	vec3 target_dir = normalize(VERTEX);
	VERTEX += target_dir * 0.1;
}
