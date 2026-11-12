shader_type canvas_item;

// Look camera de surveillance : niveaux de gris teintes vert, lignes de balayage, vignettage

uniform vec3 tint = vec3(0.55, 1.0, 0.6);
uniform float scanlines = 160.0;
uniform float scan_strength = 0.18;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	float scan = 1.0 - scan_strength * (0.5 + 0.5 * sin(UV.y * scanlines * 6.2832));
	vec2 centered = UV - 0.5;
	float vignette = 1.0 - dot(centered, centered) * 1.6;
	COLOR = vec4(tint * (0.15 + gray * 0.9) * scan * vignette, color.a);
}
