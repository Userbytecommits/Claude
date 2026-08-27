shader_type canvas_item;

uniform float pulse_speed = 2.0;
uniform float pulse_intensity = 0.1;
uniform sampler2D texture_normal : hint_normal;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float pulse = sin(TIME * pulse_speed) * pulse_intensity;
	tex.rgb += pulse;

	COLOR = tex;
}
