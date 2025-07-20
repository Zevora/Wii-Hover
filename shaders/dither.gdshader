/*
This shader is under MIT license. Feel free to use, improve and
change this shader according to your needs and consider sharing
the modified result to godotshaders.com.
*/

shader_type canvas_item;

uniform sampler2D u_dither_tex : repeat_enable;
uniform sampler2D u_color_tex;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

uniform int u_bit_depth = 8;
uniform float u_contrast = 1.0;
uniform float u_offset = 0.0;
uniform int u_dither_size = 1;

void fragment()
{
	// sample the screen texture at the desired output resolution (according to u_dither_size)
	// this will effectively pixelate the resulting output
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, 0)) / float(u_dither_size);
	vec2 screen_sample_uv = floor(UV * screen_size) / screen_size;
	vec3 screen_col = texture(SCREEN_TEXTURE, screen_sample_uv).rgb;

	// calculate pixel luminosity
	float lum = (screen_col.r * 0.299) + (screen_col.g * 0.587) + (screen_col.b * 0.114);

	// adjust with contrast and offset parameters
	float contrast = u_contrast;
	lum = (lum - 0.5 + u_offset) * contrast + 0.5;
	lum = clamp(lum, 0.0, 1.0);

	// reduce luminosity bit depth to give a more banded visual if desired
	float bits = float(u_bit_depth);
	lum = floor(lum * bits) / bits;

	// multicolor dithering
	ivec2 col_size = textureSize(u_color_tex, 0);
	col_size /= col_size.y;

	float col_x = float(col_size.x) - 1.0; // color boundaries
	float col_texel_size = 1.0 / col_x; // size of one color band

	lum = max(lum - 0.00001, 0.0); // ensures floor calculation behaves when lum == 1.0
	float lum_lower = floor(lum * col_x) * col_texel_size;
	float lum_upper = (floor(lum * col_x) + 1.0) * col_texel_size;
	float lum_scaled = lum * col_x - floor(lum * col_x); // calculates where lum lies between the upper and lower bound

	// map the dither texture onto the screen
	ivec2 noise_size = textureSize(u_dither_tex, 0);
	vec2 inv_noise_size = vec2(1.0 / float(noise_size.x), 1.0 / float(noise_size.y));
	vec2 noise_uv = UV * inv_noise_size * vec2(float(screen_size.x), float(screen_size.y));
	float threshold = texture(u_dither_tex, noise_uv).r;

	// adjust the dither threshold slightly
	threshold = threshold * 0.99 + 0.005;

	// dithering calculation
	float ramp_val = lum_scaled < threshold ? 0.0f : 1.0f;
	float col_sample = mix(lum_lower, lum_upper, ramp_val);
	vec3 final_col = texture(u_color_tex, vec2(col_sample, 0.5)).rgb;

	// output the final color
	COLOR = vec4(final_col, 1.0);
}
