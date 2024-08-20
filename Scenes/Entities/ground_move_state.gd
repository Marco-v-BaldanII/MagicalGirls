extends State
class_name GroundMoveState

var player : Player

func enter():
	GDSync.expose_node(self)
	crouching = false
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
	await get_tree().create_timer(0.5).timeout
	#player.animation_tree["parameters/conditions/not_crouch"] = true

var crouching : bool = false

func physics_update(delta : float):
	if player.can_move == false or player.lag: 
		return
	
	if Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["move_right"]) or Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_X) == 1:
		player.input_direction = 1

	elif Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["move_left"]) or Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_X) == -1:
		player.input_direction =  -1
	else:
		player.input_direction -= 0.1
		player.input_direction = clamp(player.input_direction, 0,1)

	if player.is_on_floor() and player.can_move: #Can move is turned on by the animation finished method
		player.jump_lag -= delta
		player.moving_backwards = false
		if(player.input_direction >= 0 and player.direction == "left") or (player.input_direction <= 0 and player.direction == "right"):
			player.velocity.x = player.input_direction * player.SPEED
			
		else:
			#move slower in your back direction
			player.velocity.x = player.input_direction * (player.SPEED*0.55)
			player.moving_backwards = true
	
	elif player.is_on_floor():
		player.jump_lag -= delta
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	
	else:
		player.grounded = false
		Transitioned.emit(self, "air_move")

	#Transition to jump
	#if player.input_buffer.has("jump") and player.is_on_floor() and player.jump_lag <= 0:
		#Transitioned.emit(self, "air_move")
		#
	var joy_x = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_X)
	var joy_y = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_Y)

	#Transition to crouch
	
	
	if player.can_move and Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["crouch"])or (joy_y ==  1 and abs(joy_x) < 0.4) and crouching == false and player.can_move:
			
			if not GameManager.online or (GameManager.online and GDSync.is_gdsync_owner(player)):
				Transitioned.emit(self, "crouch")
				crouching = true
				
			if GameManager.online and GDSync.is_gdsync_owner(player):
				GDSync.call_func(transition_to_crouch)
			



func transition_to_crouch():
	Transitioned.emit(self, "crouch")
	crouching = true
