shader_type spatial;
render_mode cull_disabled, unshaded;

void fragment() {
	ALBEDO = COLOR.rgb;
}
