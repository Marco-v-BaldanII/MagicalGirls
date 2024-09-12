@tool
extends GPUParticles2D

@export var viewportTexture : bool
@export var total_frames : int = 0

func _ready():
	if !viewportTexture:
		texture = get_parent().texture

	process_material = process_material.duplicate()

func _process(delta):

	#original
	# Get the total number of horizontal and vertical frames
	var hframes = get_parent().hframes
	var vframes = get_parent().vframes
	if total_frames == 0: total_frames = hframes * vframes
	
	# Get the current frame index (linear index assuming the frames are numbered row-major)
	var current_frame = $"..".frame
	var total_frames = hframes * vframes
	var frame_index = current_frame % total_frames
	#print("irhrtihj")
	# Pass the frame index directly to the shader
	process_material.set_shader_parameter("tex_anim_offset", float(frame_index)/total_frames)
