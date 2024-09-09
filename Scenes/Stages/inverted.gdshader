shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 inverted_color = vec4(1.0f -screen_color.r ,1.0f -screen_color.g,1.0f - screen_color.b, screen_color.a);
	
	COLOR = inverted_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
