shader_type spatial;
render_mode unshaded;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
void fragment()
{
	float basic_fresnel = 1.0 - fresnel(0.5, NORMAL, VIEW);
	ALBEDO = COLOR.rgb * basic_fresnel;
}