shader_type canvas_item;

uniform float damage_flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	tex.r += damage_flash * 0.5;
	tex.a = mix(tex.a, 1.0, damage_flash * 0.3);

	COLOR = tex;
}
