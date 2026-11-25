shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_front, unshaded;

uniform vec4 volume_color : source_color = vec4(0.2, 0.5, 0.6, 1.0);
uniform float volume_density : hint_range(0.01, 5.0) = 1.5;
uniform int ray_steps : hint_range(4, 64) = 16;
uniform float edge_fade : hint_range(0.01, 2.0) = 0.5;

// Godot 4 uniform setup for the depth texture
uniform sampler2D depth_texture : hint_depth_texture, filter_linear, repeat_disable;

vec2 ray_box_intersection(vec3 ro, vec3 rd, vec3 box_min, vec3 box_max) {
    vec3 t0 = (box_min - ro) / rd;
    vec3 t1 = (box_max - ro) / rd;
    vec3 tmin = min(t0, t1);
    vec3 tmax = max(t0, t1);
    
    float dst_a = max(max(tmin.x, tmin.y), tmin.z);
    float dst_b = min(min(tmax.x, tmax.y), tmax.z);
    
    float dst_to_box = max(0.0, dst_a);
    float dst_inside_box = max(0.0, dst_b - dst_to_box);
    
    return vec2(dst_to_box, dst_inside_box);
}

void fragment() {
    // 1. Corrected NDC and depth conversion for the OpenGL Compatibility backend
    float depth = texture(depth_texture, SCREEN_UV).r;
    
    // OpenGL NDC depth range must span from -1.0 to 1.0 instead of 0.0 to 1.0
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth * 2.0 - 1.0); 
    
    vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view_pos.xyz /= view_pos.w;
    float scene_depth = -view_pos.z; 

    // 2. Setup local space Ray variables
    vec3 ro_view = vec3(0.0);
    vec3 rd_view = normalize(VERTEX);
    float ray_length_to_mesh = length(VERTEX);

    vec3 ro_local = (inverse(MODEL_MATRIX) * INV_VIEW_MATRIX * vec4(ro_view, 1.0)).xyz;
    vec3 rd_local = normalize((inverse(MODEL_MATRIX) * INV_VIEW_MATRIX * vec4(rd_view, 0.0)).xyz);
    
    // 3. Compute AABB Box Intersection boundaries
    vec3 box_min = vec3(-0.5);
    vec3 box_max = vec3(0.5);
    vec2 hit_info = ray_box_intersection(ro_local, rd_local, box_min, box_max);
    
    float dist_to_box = hit_info.x;
    float dist_inside_box = hit_info.y;
    
    if (dist_inside_box <= 0.0) {
        discard;
    }

    // 4. Clip ray trajectory based on scene geometry intersections
    float max_ray_dist = scene_depth - ray_length_to_mesh + dist_to_box;
    float actual_march_dist = min(dist_inside_box, max_ray_dist);
    
    if (actual_march_dist <= 0.0) {
        discard;
    }

    // 5. Accumulate depth values inside raymarching loop
    float optical_depth = 0.0;
    float step_size = actual_march_dist / float(ray_steps);
    
    for (int i = 0; i < ray_steps; i++) {
        float current_dist = dist_to_box + step_size * (float(i) + 0.5);
        vec3 sample_pos = ro_local + rd_local * current_dist;
        
        // Edge falloff calculations
        vec3 distance_from_center = abs(sample_pos);
        vec3 box_edge_falloff = smoothstep(vec3(0.5), vec3(0.5 - edge_fade * 0.1), distance_from_center);
        float edge_density_multiplier = box_edge_falloff.x * box_edge_falloff.y * box_edge_falloff.z;
        
        optical_depth += volume_density * step_size * edge_density_multiplier;
    }
    
    // 6. Output final fragment colors
    float alpha = 1.0 - exp(-optical_depth);
    ALBEDO = volume_color.rgb;
    ALPHA = alpha * volume_color.a;
}
