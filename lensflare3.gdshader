shader_type canvas_item;
render_mode blend_add, unshaded;

uniform vec2 sun_position = vec2(640.0, 360.0); // Pixel posisi matahari
uniform vec3 tint = vec3(1.4, 1.2, 1.0); // Tint = warna + intensitas

const float streak_alpha = 0.4;
const float ghost_strength = 0.0;
const float bloom_radius = 0.05;

vec3 lens_flare(vec2 uv, vec2 pos, vec2 texResolution) {
	vec2 main = uv - pos;
	vec2 uvd = uv * length(uv);

	float ang = atan(main.x, main.y);
	float dist = length(main);
	dist = pow(dist, 0.1);

	float f1 = max(0.01 - pow(length(uv + 1.2 * pos), 1.9), 0.0) * 7.0;

	float f2 = max(1.0 / (1.0 + 32.0 * pow(length(uvd + 0.8 * pos), 2.0)), 0.0) * 0.25;
	float f22 = max(1.0 / (1.0 + 32.0 * pow(length(uvd + 0.85 * pos), 2.0)), 0.0) * 0.23;
	float f23 = max(1.0 / (1.0 + 32.0 * pow(length(uvd + 0.9 * pos), 2.0)), 0.0) * 0.21;

	vec2 uvx = mix(uv, uvd, -0.5);
	float f4 = max(0.01 - pow(length(uvx + 0.4 * pos), 2.4), 0.0) * 6.0;
	float f42 = max(0.01 - pow(length(uvx + 0.45 * pos), 2.4), 0.0) * 5.0;
	float f43 = max(0.01 - pow(length(uvx + 0.5 * pos), 2.4), 0.0) * 3.0;

	uvx = mix(uv, uvd, -0.4);
	float f5 = max(0.01 - pow(length(uvx + 0.2 * pos), 5.5), 0.0) * 2.0;
	float f52 = max(0.01 - pow(length(uvx + 0.4 * pos), 5.5), 0.0) * 2.0;
	float f53 = max(0.01 - pow(length(uvx + 0.6 * pos), 5.5), 0.0) * 2.0;

	uvx = mix(uv, uvd, -0.5);
	float f6 = max(0.01 - pow(length(uvx - 0.3 * pos), 1.6), 0.0) * 6.0;
	float f62 = max(0.01 - pow(length(uvx - 0.325 * pos), 1.6), 0.0) * 3.0;
	float f63 = max(0.01 - pow(length(uvx - 0.35 * pos), 1.6), 0.0) * 5.0;

	vec3 c = vec3(0.0);
	c.r += f2 + f4 + f5 + f6;
	c.g += f22 + f42 + f52 + f62;
	c.b += f23 + f43 + f53 + f63;

	// Apply tint intensity only (not color here)
	return c * length(tint);
}

vec3 flare_streak(vec2 uv, vec2 light_pos) {
	vec2 offset = uv - light_pos;
	float horz = exp(-abs(offset.y) * 500.0);
	float fade = smoothstep(0.5, -0.1, abs(offset.x));
	return tint * horz * fade * streak_alpha * length(tint);
}

vec3 flare_ghosts(vec2 uv, vec2 light_pos) {
	vec2 offset = uv - light_pos;
	vec3 result = vec3(0.0);
	for (int i = 1; i <= 3; i++) {
		float scale = float(i) * 0.3;
		vec2 ghost_uv = light_pos - offset * scale;
		float d = length(ghost_uv - light_pos);
		float s = exp(-d * 8.0);
		vec3 col = mix(vec3(1.0, 0.8, 0.6), vec3(0.5, 0.8, 1.0), float(i) / 3.0);
		result += col * s / float(i);
	}
	return result * ghost_strength * tint * length(tint);
}

vec3 bloom_glow(vec2 uv, vec2 light_pos) {
	float d = length(uv - light_pos);
	float bloom = exp(-pow(d / bloom_radius, 0.2));
	return tint * bloom * length(tint);
}

void fragment() {
	vec2 texResolution = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;

	vec2 uv = FRAGCOORD.xy / resolution - vec2(0.5);
	uv.x *= resolution.x / resolution.y;

	vec2 light_pos = sun_position / resolution - vec2(0.5);
	light_pos.x *= resolution.x / resolution.y;

	vec3 col_flare = lens_flare(uv, light_pos, texResolution);
	vec3 col_bloom = bloom_glow(uv + vec2(0.5), light_pos + vec2(0.5));
	vec3 col_streak = flare_streak(uv + vec2(0.5), light_pos + vec2(0.5));
	vec3 col_ghosts = flare_ghosts(uv + vec2(0.5), light_pos + vec2(0.5));

	vec3 final = col_flare + col_bloom + col_ghosts;

	final = pow(final, vec3(0.92));
	final = clamp(final, 0.0, 1.0);

	float alpha = max(max(final.r, final.g), final.b);
	COLOR = vec4(final, alpha);
}