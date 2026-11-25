shader_type canvas_item;

uniform float offset : hint_range(0.0, 10.0) = 1.0;
uniform sampler2D screen_tex : hint_screen_texture;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    vec4 col = vec4(0.0);
    
    col += texture(screen_tex, uv + vec2(offset, offset) * SCREEN_PIXEL_SIZE);
    col += texture(screen_tex, uv + vec2(-offset, offset) * SCREEN_PIXEL_SIZE);
    col += texture(screen_tex, uv + vec2(offset, -offset) * SCREEN_PIXEL_SIZE);
    col += texture(screen_tex, uv + vec2(-offset, -offset) * SCREEN_PIXEL_SIZE);

    col *= 0.25;
    
    COLOR = col;
}