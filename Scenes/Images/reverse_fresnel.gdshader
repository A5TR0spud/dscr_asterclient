shader_type spatial;
render_mode unshaded;
uniform vec3 col: source_color = vec3(1.0);

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
void fragment()
{
	float basic_fresnel = 1.0 - fresnel(0.5, NORMAL, VIEW);
	ALBEDO = col * basic_fresnel;
}