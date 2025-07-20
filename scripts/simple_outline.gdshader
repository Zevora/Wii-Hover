shader_type spatial;
render_mode unshaded, cull_front;

uniform vec4 outline_color : source_color = vec4(0.1, 0.8, 1.0, 1.0);
uniform float outline_thickness = 0.05;

void vertex() {
    VERTEX += NORMAL * outline_thickness;
}

void fragment() {
    ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}
