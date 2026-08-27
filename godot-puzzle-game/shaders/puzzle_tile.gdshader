shader_type canvas_item;

uniform float glow_intensity = 0.5;
uniform vec3 glow_color : hint_color = vec3(0.2, 0.6, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	vec2 center = UV - vec2(0.5);
	float dist = length(center);
	float glow = sin(dist * 10.0 - TIME * 3.0) * 0.5 + 0.5;

	tex.rgb = mix(tex.rgb, glow_color, glow * glow_intensity * 0.5);

	COLOR = tex;
}
