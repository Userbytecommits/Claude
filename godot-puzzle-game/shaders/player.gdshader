shader_type canvas_item;

uniform float pulse_speed = 2.0;
uniform float pulse_intensity = 0.06;
uniform float damage_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float pulse = sin(TIME * pulse_speed) * pulse_intensity;
	tex.rgb += pulse * tex.a;

	tex.rgb = mix(tex.rgb, vec3(1.0, 0.25, 0.25), damage_flash * tex.a);

	COLOR = tex;
}
