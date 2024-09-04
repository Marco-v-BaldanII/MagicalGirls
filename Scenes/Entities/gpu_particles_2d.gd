@tool
extends GPUParticles2D

@export var viewportTexture : bool

func _ready():
	if !viewportTexture:
		texture = get_parent().texture

func _process(delta):

	#original
	# Get the total number of horizontal and vertical frames
	var hframes = get_parent().hframes
	var vframes = get_parent().vframes

	# Get the current frame index (linear index assuming the frames are numbered row-major)
	var current_frame = $"..".frame
	var total_frames = hframes * vframes
	var frame_index = current_frame % total_frames

	# Pass the frame index directly to the shader
	process_material.set_shader_parameter("tex_anim_offset", float(frame_index)/108.0)
