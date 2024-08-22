extends Player
class_name AI_Player

@export var attack_distance : int = 380

func press_input(input : String):
	action_state[input] = true
	input_buffer.push_back(input)
	perform_move()
	await get_tree().create_timer(0.01667).timeout
	action_state[input] = false

func _process(delta):
	if input_made:
		buffer_time -= delta
	
		if buffer_time <= 0:
			clear_buffer()
		
	#Auto turn around logic
	if direction == "left" and oponent and oponent.global_position.x < global_position.x:
		scale.x *= -1
		direction = "right"
	elif direction == "right" and oponent and oponent.global_position.x > global_position.x:
		scale.x *= -1
		direction = "left"

func _input(event):
	
	return
	#The ai doesn't get input
	
	if not GameManager.online or GDSync.is_gdsync_owner(self):
		joy_x = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X)
		joy_y = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_Y)
		
		if is_joy_button_just_pressed("move_left") or (joy_x == -1 and abs(joy_y) < 0.4):
			add_input_to_buffer("move_left")
			perform_move()
		if is_joy_button_just_pressed("move_right") or (joy_x == 1 and abs(joy_y) <0.4):
			add_input_to_buffer("move_right")
			perform_move()
		if is_joy_button_just_pressed("crouch") or (joy_y ==  1 and abs(joy_x) < 0.4):
			add_input_to_buffer("crouch")
			perform_move()
		if is_joy_button_just_pressed("jump") or (joy_y < -0.2 and abs(joy_x) < 0.4 ):
			#print("jump with a y of " + str(joy_y) +"and a x of " + str(joy_x))
			add_input_to_buffer("jump")
			perform_move()
		if is_joy_button_just_pressed("s_punch"):
			add_input_to_buffer("s_punch")
			perform_move()
		if is_joy_button_just_pressed("w_punch"):
			add_input_to_buffer("w_punch")
			perform_move()
		if is_joy_button_just_pressed("s_kick"):
			add_input_to_buffer("s_kick")
			perform_move()
		if is_joy_button_just_pressed("w_kick"):
			add_input_to_buffer("w_kick")
			perform_move()
		
