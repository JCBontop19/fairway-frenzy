shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.55;
uniform float softness : hint_range(0.0, 1.0) = 0.45;
uniform vec4 color : source_color = vec4(0.0, 0.0, 0.0, 0.6);

void fragment() {
    vec2 uv = UV - vec2(0.5);  
    float dist = length(uv);

    // Instead of fading IN at center, we fade OUT
    float vignette = 1.0 - smoothstep(radius, radius - softness, dist);

    // Fade edges while keeping center bright
    COLOR = vec4(color.rgb, color.a * vignette);
}